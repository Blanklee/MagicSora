unit Client1;

interface

uses
  System.SysUtils, IdTCPClient, FMX.ListView;

const
  GRAY  = 0;
  RED   = 1;
  GREEN = 2;

type
  TClient = class
  private
    Solution: string;
    Server: string;
    Port: integer;
    Socket: TIdTCPClient;
    FIsOpen: boolean;
    FErrorMessage: string;
    procedure IdTCPClient1Connected(Sender: TObject);
  public
    item: TListViewItem;
    constructor Create;
    destructor Destroy; override;
    procedure SetSocket(ASolution, AServer: string; APort: integer);
    procedure Run;
    property IsOpen: boolean read FIsOpen;
    property ErrorMessage: string read FErrorMessage;
  end;

implementation

{ TClient }

constructor TClient.Create;
begin
  Inherited Create;
  Socket:= TIdTCPClient.Create(nil);
  Socket.ConnectTimeout:= 3000;
  Socket.ReadTimeout:= 3000;
  Socket.OnConnected:= IdTCPClient1Connected;
  // Socket.OnDisconnected:= IdTCPClient1Disconnected;
end;

destructor TClient.Destroy;
begin
  Socket.Free;
  Inherited Destroy;
end;

procedure TClient.IdTCPClient1Connected(Sender: TObject);
begin
  // Port가 살아있다
  FIsOpen:= True;
  item.Detail:= ' 결과 : Open';
  item.ImageIndex:= GREEN;

  // 확인되었으므로 바로 연결해제
  Socket.Disconnect;
end;

procedure TClient.SetSocket(ASolution, AServer: string; APort: integer);
begin
  Solution:= ASolution;
  Server:= AServer;
  Port:= APort;
  FIsOpen:= False;
  Socket.Host:= Server;
  Socket.Port:= Port;

  // item에 출력한다
  item.Text:= Solution + ' / ' + Server + '  (' + inttostr(Port) + ')';
  item.ButtonText:= ' Test ';
end;

procedure TClient.Run;
begin
  FIsOpen:= False;
  item.Detail:= '';
  item.ImageIndex:= GRAY;

  if Socket.Host = '' then exit;
  if Socket.Port = 0 then exit;

  try
    // 연결 시도해 본다
    Socket.Disconnect;
    Socket.Connect;
  except
    // Port가 죽어있다
    // On E: EIdSocketError do FErrorMessage:= E.Message;
    FIsOpen:= False;
    item.Detail:= ' 결과 : Closed';
    item.ImageIndex:= RED;
  end;
end;

end.
