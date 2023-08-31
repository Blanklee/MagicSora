unit MainForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, IdIntercept, FMX.ScrollBox, FMX.Memo,
  FMX.ListView.Types, FMX.ListView, Client1, System.ImageList, FMX.ImgList, FMX.Layouts,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal, IdStack,
  FMX.TabControl;

const
  MAX = 100;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    RunButton: TButton;
    StopButton: TButton;
    ConfigButton: TButton;
    ExitButton: TButton;
    ListView1: TListView;
    BallImageList1: TImageList;
    IdTCPClient1: TIdTCPClient;
    Timer1: TTimer;
    Layout1: TLayout;
    TabControl1: TTabControl;
    TabItem_Main: TTabItem;
    TabItem_Config: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure RunButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure ConfigButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FCount: integer;
    cl: array[0..MAX] of TClient;
    procedure LoadFromIniFile;
    // procedure SaveToIniFile;
  public
    { Public declarations }
    procedure GotoMainTab(Save: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses ConfigForm1, System.IniFiles;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // 첫번째탭(Main) 띄우고, 탭은 숨긴다
  TabControl1.ActiveTab:= TabItem_Main;
  TabControl1.TabPosition:= TTabPosition.None;

  // Form 생성 및 Parent 조정
  ConfigForm:= TConfigForm.Create(Self);
  ConfigForm.Layout1.Parent:= TabItem_Config;

  // Client 생성
  for i:= 0 to MAX do cl[i]:= TClient.Create;

  // ini 파일로부터 Socket 초기화 (ini 파일은 ConfigForm.Create 통해 항상 존재함)
  LoadFromIniFile;

  {
  // Client 생성 : item 생성도 LoadFromIniFile에서 수행됨
  for i:= 0 to MAX do
  begin
    cl[i]:= TClient.Create;
    item:= ListView1.Items.Add;
    item.ImageIndex:= GRAY;
    cl[i].item:= item;
    // item을 보고 Client를 찾아갈수 있게 번호를 매겨둔다
    item.Tag:= i;
  end;

  // 이하는 LoadFromIniFile에 의해 자동으로 수행됨
  // cl[0].SetSocket(...);
  // cl[1].SetSocket('Test', '127.0.0.1', 80);
  // cl[2].SetSocket('Test', '127.0.0.1', 3306);
  // cl[1].SetSocket('Test', '192.168.1.2', 80);
  // cl[2].SetSocket('Test', '192.168.1.2', 3306);
  cl[ 0].SetSocket(...);
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
  }
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  Timer1.Enabled:= False;
  ListView1.Items.Clear;
  for i:= 0 to MAX do cl[i].Free;
  ConfigForm.Free;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // 스마트폰의 뒤로가기 버튼을 누르면 (정확히 말하면 떼면)
  if (Key = vkHardwareBack)
  // 또는 Windows에서는 Ctrl-Shift-Left를 누르면 (디버그용)
  or ((Key = vkLeft) and (ssCtrl in Shift)) then

  // Config 화면이라면
  if (TabControl1.ActiveTab = TabItem_Config) then
  begin
    // 종료하지 말고 Cancel 버튼 클릭한 것처럼 동작하라
    Key:= 0;
    ConfigForm.CancelButtonClick(Sender);
  end else

  // Back 누르면 그냥 종료돼 버리는데, 종료할지 물어보고 종료한다
  if (TabControl1.ActiveTab = TabItem_Main) then
  begin
    // 일단 종료하지 말고 (여기서 안해주면 MessageDlg도 안뜨고 바로 종료돼 버리며
    // MessageDlg 관련 찌꺼기가 쓸데없이 남아서 다음 재실행시 먹통된다)
    Key:= 0;
    // 물어보고 종료한다
    ExitButtonClick(Sender);
  end;
end;

procedure TMainForm.LoadFromIniFile;
var
  IniFile: TIniFile;
  i, Count, Section, Port: integer;
  SectionName, SolutionName, SolutionServer: string;
  item: TListViewItem;
begin
  // ListView를 Clear한다
  ListView1.Items.Clear;
  Count:= 0;
  Section:= 0;

  { // ini 파일은 아래와 같이 작성되어 있음
  [Test]
  SolutionName=Test
  SolutionServer=192.168.1.2
  Port1=80
  Port2=3306

  [Solution1]
  SolutionName=CounThru
  SolutionServer=192.1.1.119
  Port1=7005
  Port2=161
  Port3=80
  Port4=25
  Port5=465
  }

  // Ini 파일에서 읽어온다
  IniFile:= TIniFile.Create(IniFileName);
  try
    repeat
      // 먼저 [Test] 또는 [Solution1] 처럼 SectionName을 생성한다
      if Section > 0 then SectionName:= 'Solution' + inttostr(Section) else SectionName:= 'Test';

      // [SectionName] 에서 SolutionName과 SolutionServer 항목을 읽는다
      SolutionName:= IniFile.ReadString(SectionName, 'SolutionName', '');
      SolutionServer:= IniFile.ReadString(SectionName, 'SolutionServer', '');

      // 항목이 존재하지 않으면 repeat 문을 벗어난다 (Section=0인 경우는 Test Section으로 예외)
      if Section > 0 then
      if (SolutionName = '') or (SolutionServer = '') then break;

      // 항목이 존재하면 Port를 1번부터 차례대로 읽어들여 item을 생성한다
      for i:= 1 to 10000 do
      begin
        // Port1, Port2 ... 읽어온다
        Port:= IniFile.ReadInteger(SectionName, 'Port'+inttostr(i), -1);
        if Port < 0 then break;

        // Port가 존재하면 item을 생성한다
        item:= ListView1.Items.Add;
        item.ImageIndex:= GRAY;
        cl[Count].item:= item;
        // item을 보고 Client를 찾아갈수 있게 번호를 매겨둔다
        item.Tag:= Count;
        // item의 값들을 세팅
        cl[Count].SetSocket(SolutionName, SolutionServer, Port);

        // 다음 cl[]의 index를 위해 Count 증가
        Count:= Count + 1;
      end;

      // 다음 Section을 위해 Section 증가
      Section:= Section + 1;
    until Section > 10000;

  finally
    IniFile.Free;
  end;
end;

{
procedure TMainForm.SaveToIniFile;
var
  IniFile: TIniFile;
begin
  // Ini 파일로 저장한다
  IniFile:= TIniFile.Create(IniFileName);
  try
    // IniFile.WriteString('Options', 'Server', edServer.Text);
    // IniFile.WriteString('Options', 'MyNumber', edMyNumber.Text);
  finally
    IniFile.Free;
  end;
end;
}

procedure TMainForm.ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
begin
  // 각 Item의 Button을 Click할 경우 해당 Port만 Check한다
  // AItem.Tag에 Client 번호가 있으므로 Client를 쉽게 찾아갈 수 있다
  Timer1.Enabled:= False;
  cl[AItem.Tag].Run;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  FCount:= FCount + 1;
  if FCount < ListView1.Items.Count
  then cl[FCount].Run
  else Timer1.Enabled:= False;
end;

procedure TMainForm.GotoMainTab(Save: integer);
begin
  // from Config
  TabControl1.ActiveTab:= TabItem_Main;

  // Save 눌렀을 경우 반영한다
  if Save = 1 then LoadFromIniFile;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 화면 초기화
  for i:= 0 to ListView1.Items.Count-1 do
  begin
    cl[i].item.Detail:= '';
    cl[i].item.ImageIndex:= GRAY;
  end;

  // 아래와 같이 하면 뻗어버림, 전부다 끝난후 한번에 결과 출력됨
  // for i:= 1 to 3 do cl[i].Run;

  // 그래서 아래와 같이 Timer 사용
  FCount:= -1;
  Timer1.Enabled:= True;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  // Run 동작을 멈춘다
  Timer1.Enabled:= False;
end;

procedure TMainForm.ConfigButtonClick(Sender: TObject);
begin
  // Run 중인 동작을 멈춘다
  Timer1.Enabled:= False;

  // 현재의 설정을 메모장으로 불러온다
  ConfigForm.LoadIniFile;

  // 설정 화면을 띄워준다
  TabControl1.ActiveTab:= TabItem_Config;
end;

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  // 물어보고 종료한다
  MessageDlg('프로그램을 종료할까요 ?',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        Timer1.Enabled:= False;
        Close;
      end;
    end);
end;

end.

