unit MainForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, IdIntercept, FMX.ScrollBox, FMX.Memo,
  FMX.ListView.Types, FMX.ListView, Client1, System.ImageList, FMX.ImgList, FMX.Layouts,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal, IdStack,
  FMX.TabControl, System.Actions, FMX.ActnList, FMX.Objects, FMX.Effects, FMX.Ani;

const
  CLMAX = 100;
  MyVersion = '매직소라 v1.3b  for Samsung DMFP.';
  MyCopyright = 'Copyright by 이경백.'#10#10 + '작성일자 : 2018. 07.';

type
  TMainForm = class(TForm)
    Layout1: TLayout;
    TabControl1: TTabControl;
    TabItem_Main: TTabItem;
    TabItem_Config: TTabItem;
    TabItem_UsbLoad: TTabItem;
    TabItem_Temp: TTabItem;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    ChangeTabAction3: TChangeTabAction;
    LabelTop: TLabel;
    LabelTemp: TLabel;
    LabelState: TLabel;
    RunButton: TButton;
    StopButton: TButton;
    ClearButton: TButton;
    ConfigButton: TButton;
    AboutButton: TButton;
    ExitButton: TButton;
    ListView1: TListView;
    BallImageList1: TImageList;
    IdTCPClient1: TIdTCPClient;
    Timer1: TTimer;
    Layout_Toast: TLayout;
    ToastRect: TRoundRect;
    ShadowEffect1: TShadowEffect;
    ToastText: TText;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
    procedure RunButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ConfigButtonClick(Sender: TObject);
    procedure AboutButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FCount: integer;
    cl: array[0..CLMAX] of TClient;
    procedure LoadFromIniFile;
    procedure ShowState(Running: boolean);
  public
    { Public declarations }
    procedure GotoMainTab(Save: integer);
    procedure ToastMessage(msg: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses ConfigForm1, System.IniFiles, UsbLoadForm1;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // LabelState가 LabelTop과 겹치지 않게 조절한다
  // FormResize 함수는 안그래도 첫실행시 두번이나 실행됨
  // FormResize(Sender);

  // 첫번째탭(Main) 띄우고, 탭은 숨긴다
  TabControl1.ActiveTab:= TabItem_Main;
  TabControl1.TabPosition:= TTabPosition.None;

  // Toast를 투명하게 해서 안보이게 한다
  Layout_Toast.Parent:= Self;
  Layout_Toast.Opacity:= 0.0;
  ToastRect.Width:= 160;

  // Form 생성 및 Parent 조정
  ConfigForm:= TConfigForm.Create(Self);
  ConfigForm.Layout1.Parent:= TabItem_Config;
  UsbLoadForm:= TUsbLoadForm.Create(Self);
  UsbLoadForm.Layout1.Parent:= TabItem_UsbLoad;

  // Client 생성
  for i:= 0 to CLMAX do cl[i]:= TClient.Create;

  // ini 파일로부터 Socket 초기화 (ini 파일은 ConfigForm.Create 통해 항상 존재함)
  LoadFromIniFile;

  {
  // Client 생성 : item 생성도 LoadFromIniFile에서 수행됨
  for i:= 0 to CLMAX do
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
  LabelState.Text:= 'Idle';

  ListView1.Items.Clear;
  for i:= 0 to CLMAX do cl[i].Free;

  ConfigForm.Free;
  UsbLoadForm.Free;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  // LabelState가 LabelTop과 겹치지 않게 조절한다
  LabelTemp.Visible:= True;
  LabelTemp.Text:= LabelTop.Text;

  // 'Idle' 기준으로 LabelTop과 겹치면 'Idle'을 왼쪽으로 이동한다
  if LabelState.Position.X + LabelState.Size.Width > LabelTemp.Position.X
  then LabelState.Position.X:= 16
  else LabelState.Position.X:= 144;

  LabelTemp.Visible:= False;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // 스마트폰의 뒤로가기 버튼을 누르면 (정확히 말하면 떼면)
  if (Key = vkHardwareBack)
  // 또는 Windows에서는 Ctrl-Shift-Left를 누르면 (디버그용)
  or ((Key = vkLeft) and (ssCtrl in Shift)) then

  // Main : Back 누르면 그냥 종료돼 버리는데, 종료할지 물어보고 종료한다
  if (TabControl1.ActiveTab = TabItem_Main) then
  begin
    // 일단 종료하지 말고 (여기서 안해주면 MessageDlg도 안뜨고 바로 종료돼 버리며
    // MessageDlg 관련 찌꺼기가 쓸데없이 남아서 다음 재실행시 먹통된다)
    Key:= 0;
    // 물어보고 종료한다
    ExitButtonClick(Sender);
  end else

  // Config 화면이라면
  if (TabControl1.ActiveTab = TabItem_Config) then
  begin
    // 가상 키보드가 보여지고 있다면 키보드 숨기는 일을 자동으로 하므로 그냥 냅둔다
    if not ConfigForm.KBVisible then
    begin
      // 종료하지 말고 Cancel 버튼 클릭한 것처럼 동작하라
      Key:= 0;
      ConfigForm.CancelButtonClick(Sender);
    end;
  end else

  // Usb Load 화면이라면
  if (TabControl1.ActiveTab = TabItem_UsbLoad) then
  begin
    // 종료하지 말고 Cancel 버튼 클릭한 것처럼 동작하라
    Key:= 0;
    UsbLoadForm.CancelButtonClick(Sender);
  end else
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
        if Count > CLMAX then break;
      end;

      // 다음 Section을 위해 Section 증가
      Section:= Section + 1;
      if Count > CLMAX then break;
    until Section > 10000;

  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  // ListView에 있는 모든 항목들에 대하여 순차적으로 Run 시킨다
  // 결과는 Client에서 알아서 출력한다
  FCount:= FCount + 1;
  if FCount < ListView1.Items.Count
  then cl[FCount].Run
  else Timer1.Enabled:= False;
end;

procedure TMainForm.GotoMainTab(Save: integer);
begin
  // from Config
  // TabControl1.ActiveTab:= TabItem_Main;
  ChangeTabAction1.ExecuteTarget(Self);

  // Save 눌렀을 경우 반영한다
  if Save = 1 then
  begin
    LoadFromIniFile;
    ToastMessage('반영되었습니다.');
  end;
end;

procedure TMainForm.ToastMessage(msg: string);
begin
  // Text를 반영하고 AutoSize로 변경된 ToastText.Width를 ToastRect.Width에 반영한다
  ToastText.Text:= msg;
  ToastRect.Width:= ToastText.Width + 48;

  // 불투명도를 1로 해서 화면에 나타나게 한다
  Layout_Toast.Opacity:= 1.0;
  // 0.8초동안 보여주고 0.7초동안 서서히 사라짐
  TAnimator.Create.AnimateFloatDelay(Layout_Toast, 'Opacity', 0.0, 0.7, 0.8);
end;

procedure TMainForm.ShowState(Running: boolean);
begin
  // 화면에 상태 표시
  if Running
  then LabelState.Text:= 'Running...'
  else LabelState.Text:= 'Idle';

  // 상태에 따라 버튼 활성화 결정
  RunButton.Enabled:= not Running;
  StopButton.Enabled:= Running;
  ClearButton.Enabled:= not Running;
  ConfigButton.Enabled:= not Running;
  ExitButton.Enabled:= not Running;
end;

procedure TMainForm.ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
begin
  // 각 Item의 Button을 Click할 경우 해당 Port만 Check한다
  Timer1.Enabled:= False;

  // 버튼 1개를 누를때는 굳이 Running.. 표시를 하지 않는다 (주석처리)
  // ShowState(True);

  // 해당 cl[]를 Run한다. cl[] 번호는 item.Tag에 저장해 두었다
  // AItem.Tag에 Client 번호가 있으므로 Client를 쉽게 찾아갈 수 있다
  cl[AItem.Tag].Run;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
begin
  // 화면 초기화
  ClearButtonClick(Sender);
  {
  for i:= 0 to ListView1.Items.Count-1 do
  begin
    cl[i].item.Detail:= '';
    cl[i].item.ImageIndex:= GRAY;
  end;
  }

  // 아래와 같이 하면 뻗어버림, 전부다 끝난후 한번에 결과 출력됨
  // for i:= 1 to 3 do cl[i].Run;

  // 그래서 아래와 같이 Timer 사용
  FCount:= -1;
  Timer1.Enabled:= True;

  // 화면에 상태 표시
  ShowState(True);
  ToastMessage('동작을 시작합니다');
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  // Run 동작을 멈춘다
  Timer1.Enabled:= False;
  ShowState(False);
  ToastMessage('동작을 중지합니다');
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
var
  i: integer;
begin
  // 실행 결과를 모두 초기화한다
  Timer1.Enabled:= False;
  ShowState(False);

  for i:= 0 to ListView1.Items.Count-1 do
  begin
    cl[i].item.Detail:= '';
    cl[i].item.ImageIndex:= GRAY;
  end;
end;

procedure TMainForm.ConfigButtonClick(Sender: TObject);
begin
  // Run 중인 동작을 멈춘다
  Timer1.Enabled:= False;
  ShowState(False);

  // 현재의 설정을 메모장으로 불러온다
  ConfigForm.LoadIniFile;

  // 설정 화면을 띄워준다
  // TabControl1.ActiveTab:= TabItem_Config;
  ChangeTabAction2.ExecuteTarget(Self);
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  ShowMessage(MyVersion + #10#10 + MyCopyright);
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

