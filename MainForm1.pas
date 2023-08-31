unit MainForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, IdIntercept, FMX.ScrollBox, FMX.Memo,
  IdLogBase, IdLogEvent, IdTelnet, IdExplicitTLSClientServerBase, IdFTP,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal, IdStack;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    IdTCPClient1: TIdTCPClient;
    IdFTP1: TIdFTP;
    IdTelnet1: TIdTelnet;
    IdLogEvent1: TIdLogEvent;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure IdLogEvent1Connect(ASender: TIdConnectionIntercept);
    procedure IdLogEvent1Disconnect(ASender: TIdConnectionIntercept);
    procedure IdLogEvent1Receive(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
    procedure IdLogEvent1Status(ASender: TComponent; const AText: string);
    procedure IdTCPClient1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Edit1.Text = '' then exit;
  if Edit2.Text = '' then exit;
  try
    IdTCPClient1.Host:= Edit1.Text;
    IdTCPClient1.Port:= StrToIntDef(Edit2.Text,0);
    if IdTCPClient1.Port = 0 then exit;
    IdTCPClient1.Connect;
  except
    On E: EIdSocketError do
    Memo1.Lines.Add(E.Message);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  IdTCPClient1.Disconnect;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.IdLogEvent1Connect(ASender: TIdConnectionIntercept);
begin
  Memo1.Lines.Add('LogEvent : 연결되었습니다');
end;

procedure TForm1.IdLogEvent1Disconnect(ASender: TIdConnectionIntercept);
begin
  Memo1.Lines.Add('LogEvent : 연결이 해제되었습니다');
end;

procedure TForm1.IdLogEvent1Receive(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
begin
  Memo1.Lines.Add('LogEvent : 데이터를 수신하였습니다');
end;

procedure TForm1.IdLogEvent1Status(ASender: TComponent; const AText: string);
begin
  Memo1.Lines.Add('LogEvent : ' + AText);
end;

procedure TForm1.IdTCPClient1Connected(Sender: TObject);
begin
  Memo1.Lines.Add('Client : 연결되었습니다');
end;

procedure TForm1.IdTCPClient1Disconnected(Sender: TObject);
begin
  Memo1.Lines.Add('Client : 연결이 해제되었습니다');
end;

procedure TForm1.IdTCPClient1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add('Client : ' + AStatusText);
end;

end.
