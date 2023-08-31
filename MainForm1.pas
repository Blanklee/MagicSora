unit MainForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, IdIntercept, FMX.ScrollBox, FMX.Memo,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal, IdStack,
  FMX.ListView.Types, FMX.ListView, Client1, System.ImageList, FMX.ImgList;

const
  MAX   = 21;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ListView1: TListView;
    BallImageList1: TImageList;
    IdTCPClient1: TIdTCPClient;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListViewItem; const AObject: TListItemSimpleControl);
  private
    { Private declarations }
    FCount: integer;
    cl: array[1..MAX] of TClient;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
  item: TListViewItem;
begin
  // Client 생성
  for i:= 1 to MAX do
  begin
    cl[i]:= TClient.Create;
    item:= ListView1.Items.Add;
    item.ImageIndex:= GRAY;
    cl[i].item:= item;
    // item을 보고 Client를 찾아갈수 있게 번호를 매겨둔다
    item.Tag:= i;
  end;

  // Socket 초기화
  // cl[1].SetSocket('Test', '127.0.0.1', 80);
  // cl[2].SetSocket('Test', '127.0.0.1', 3306);
  // cl[1].SetSocket('Test', '192.168.1.2', 80);
  // cl[2].SetSocket('Test', '192.168.1.2', 3306);
  cl[ 1].SetSocket('CounThru', '192.1.1.119', 7005);
  cl[ 2].SetSocket('CounThru', '192.1.1.119', 161);
  cl[ 3].SetSocket('CounThru', '192.1.1.119', 80);
  cl[ 4].SetSocket('CounThru', '192.1.1.119', 25);
  cl[ 5].SetSocket('CounThru', '192.1.1.119', 465);
  cl[ 6].SetSocket('SPS', '192.1.1.131', 80);
  cl[ 7].SetSocket('SPS', '192.1.1.131', 5000);
  cl[ 8].SetSocket('SPS', '192.1.1.131', 5443);
  cl[ 9].SetSocket('SPS', '192.1.1.131', 21);
  cl[10].SetSocket('SPS', '192.1.1.131', 990);
  cl[11].SetSocket('SPS', '192.1.1.131', 9100);
  cl[12].SetSocket('SPS', '192.1.1.131', 9900);
  cl[13].SetSocket('SPS', '192.1.1.131', 9443);
  cl[14].SetSocket('SPS', '192.1.1.131', 161);
  cl[15].SetSocket('SPS', '192.1.1.131', 1443);
  cl[16].SetSocket('e-Fax', '192.1.1.126', 80);
  cl[17].SetSocket('e-Fax', '192.1.1.126', 443);
  cl[18].SetSocket('e-Fax', '192.1.1.126', 161);
  cl[19].SetSocket('e-Fax', '192.1.1.126', 9402);
  cl[20].SetSocket('e-Fax', '192.1.1.126', 25);
  cl[21].SetSocket('e-Fax', '192.1.1.126', 21);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  Timer1.Enabled:= False;
  ListView1.ClearItems;
  for i:= 1 to MAX do cl[i].Free;
end;

procedure TForm1.ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
begin
  // 각 Item의 Button을 Click할 경우 해당 Port만 Check한다
  // AItem.Tag에 Client 번호가 있으므로 Client를 쉽게 찾아갈 수 있다
  Timer1.Enabled:= False;
  cl[AItem.Tag].Run;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  FCount:= FCount + 1;
  if FCount <= MAX
  then cl[FCount].Run
  else Timer1.Enabled:= False;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  // Run

  // 화면 초기화
  for i:= 1 to MAX do
  begin
    cl[i].item.Detail:= '';
    cl[i].item.ImageIndex:= GRAY;
  end;

  // 아래와 같이 하면 뻗어버림, 전부다 끝난후 한번에 결과 출력됨
  // for i:= 1 to 3 do cl[i].Run;

  // 그래서 아래와 같이 Timer 사용
  FCount:= 0;
  Timer1.Enabled:= True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1.Enabled:= False;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Config
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Timer1.Enabled:= False;
  Close;
end;

end.

