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
  CLMAX = 100;

type
  TMainForm = class(TForm)
    LabelTitle: TLabel;
    RunButton: TButton;
    StopButton: TButton;
    ConfigButton: TButton;
    ExitButton: TButton;
    ListView1: TListView;
    BallImageList1: TImageList;
    IdTCPClient1: TIdTCPClient;
    Timer1: TTimer;
    MainLayout1: TLayout;
    TabControl1: TTabControl;
    TabItem_Main: TTabItem;
    TabItem_Config: TTabItem;
    VertScrollBox1: TVertScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure RunButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure ConfigButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
    procedure Timer1Timer(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure VertScrollBox1CalcContentBounds(Sender: TObject; var ContentBounds: TRectF);
  private
    { Private declarations }
    FCount: integer;
    cl: array[0..CLMAX] of TClient;
    FKBVisible: boolean;
    FKBBounds: TRectF;
    FNeedOffset: boolean;
    procedure LoadFromIniFile;
    procedure _RestorePosition;
    procedure _UpdateKBBounds;
  public
    { Public declarations }
    procedure GotoMainTab(Save: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses System.Math, System.IniFiles, ConfigForm1;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // ���� �ʱ�ȭ
  FKBVisible:= false;

  // ù��°��(Main) ����, ���� �����
  TabControl1.ActiveTab:= TabItem_Main;
  TabControl1.TabPosition:= TTabPosition.None;

  // Form ���� �� Parent ����
  ConfigForm:= TConfigForm.Create(Self);
  ConfigForm.Layout1.Parent:= TabItem_Config;

  // Client ����
  for i:= 0 to CLMAX do cl[i]:= TClient.Create;

  // ini ���Ϸκ��� Socket �ʱ�ȭ (ini ������ ConfigForm.Create ���� �׻� ������)
  LoadFromIniFile;

  {
  // Client ���� : item ������ LoadFromIniFile���� �����
  for i:= 0 to CLMAX do
  begin
    cl[i]:= TClient.Create;
    item:= ListView1.Items.Add;
    item.ImageIndex:= GRAY;
    cl[i].item:= item;
    // item�� ���� Client�� ã�ư��� �ְ� ��ȣ�� �Űܵд�
    item.Tag:= i;
  end;

  // ���ϴ� LoadFromIniFile�� ���� �ڵ����� �����
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
  for i:= 0 to CLMAX do cl[i].Free;
  ConfigForm.Free;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // ����Ʈ���� �ڷΰ��� ��ư�� ������ (��Ȯ�� ���ϸ� ����)
  if (Key = vkHardwareBack)
  // �Ǵ� Windows������ Ctrl-Shift-Left�� ������ (����׿�)
  or ((Key = vkLeft) and (ssCtrl in Shift)) then

  // ���� Ű���尡 �������� �ִٸ� Ű���� ����� ���� �ڵ����� �ϹǷ� �׳� ���д�
  if not FKBVisible then

  // Config ȭ���̶��
  if (TabControl1.ActiveTab = TabItem_Config) then
  begin
    // �������� ���� Cancel ��ư Ŭ���� ��ó�� �����϶�
    Key:= 0;
    ConfigForm.CancelButtonClick(Sender);
  end else

  // Back ������ �׳� ����� �����µ�, �������� ����� �����Ѵ�
  if (TabControl1.ActiveTab = TabItem_Main) then
  begin
    // �ϴ� �������� ���� (���⼭ �����ָ� MessageDlg�� �ȶ߰� �ٷ� ����� ������
    // MessageDlg ���� ��Ⱑ �������� ���Ƽ� ���� ������ ����ȴ�)
    Key:= 0;
    // ����� �����Ѵ�
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
  // ListView�� Clear�Ѵ�
  ListView1.Items.Clear;
  Count:= 0;
  Section:= 0;

  { // ini ������ �Ʒ��� ���� �ۼ��Ǿ� ����
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

  // Ini ���Ͽ��� �о�´�
  IniFile:= TIniFile.Create(IniFileName);
  try
    repeat
      // ���� [Test] �Ǵ� [Solution1] ó�� SectionName�� �����Ѵ�
      if Section > 0 then SectionName:= 'Solution' + inttostr(Section) else SectionName:= 'Test';

      // [SectionName] ���� SolutionName�� SolutionServer �׸��� �д´�
      SolutionName:= IniFile.ReadString(SectionName, 'SolutionName', '');
      SolutionServer:= IniFile.ReadString(SectionName, 'SolutionServer', '');

      // �׸��� �������� ������ repeat ���� ����� (Section=0�� ���� Test Section���� ����)
      if Section > 0 then
      if (SolutionName = '') or (SolutionServer = '') then break;

      // �׸��� �����ϸ� Port�� 1������ ���ʴ�� �о�鿩 item�� �����Ѵ�
      for i:= 1 to 10000 do
      begin
        // Port1, Port2 ... �о�´�
        Port:= IniFile.ReadInteger(SectionName, 'Port'+inttostr(i), -1);
        if Port < 0 then break;

        // Port�� �����ϸ� item�� �����Ѵ�
        item:= ListView1.Items.Add;
        item.ImageIndex:= GRAY;
        cl[Count].item:= item;
        // item�� ���� Client�� ã�ư��� �ְ� ��ȣ�� �Űܵд�
        item.Tag:= Count;
        // item�� ������ ����
        cl[Count].SetSocket(SolutionName, SolutionServer, Port);

        // ���� cl[]�� index�� ���� Count ����
        Count:= Count + 1;
      end;

      // ���� Section�� ���� Section ����
      Section:= Section + 1;
    until Section > 10000;

  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.ListView1ButtonClick(const Sender: TObject; const AItem: TListViewItem; const AObject: TListItemSimpleControl);
begin
  // �� Item�� Button�� Click�� ��� �ش� Port�� Check�Ѵ�
  // AItem.Tag�� Client ��ȣ�� �����Ƿ� Client�� ���� ã�ư� �� �ִ�
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

  // Save ������ ��� �ݿ��Ѵ�
  if Save = 1 then LoadFromIniFile;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  i: integer;
begin
  // ȭ�� �ʱ�ȭ
  for i:= 0 to ListView1.Items.Count-1 do
  begin
    cl[i].item.Detail:= '';
    cl[i].item.ImageIndex:= GRAY;
  end;

  // �Ʒ��� ���� �ϸ� �������, ���δ� ������ �ѹ��� ��� ��µ�
  // for i:= 1 to 3 do cl[i].Run;

  // �׷��� �Ʒ��� ���� Timer ���
  FCount:= -1;
  Timer1.Enabled:= True;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  // Run ������ �����
  Timer1.Enabled:= False;
end;

procedure TMainForm.ConfigButtonClick(Sender: TObject);
begin
  // Run ���� ������ �����
  Timer1.Enabled:= False;

  // ������ ������ �޸������� �ҷ��´�
  ConfigForm.LoadIniFile;

  // ���� ȭ���� ����ش�
  TabControl1.ActiveTab:= TabItem_Config;
end;

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  // ����� �����Ѵ�
  MessageDlg('���α׷��� �����ұ�� ?',
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










// --------------------------------------------------------------------
// ���⼭����: ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
// --------------------------------------------------------------------

procedure TMainForm.FormFocusChanged(Sender: TObject);
begin
  _UpdateKBBounds;
end;

procedure TMainForm.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBVisible:= false;

  // ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset:= False;
  _RestorePosition;
end;

procedure TMainForm.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBVisible:= true;

  // ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
  FKBBounds:= TRectF.Create(Bounds);
  FKBBounds.TopLeft:= ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight:= ScreenToClient(FKBBounds.BottomRight);
  _UpdateKBBounds;
end;

procedure TMainForm.VertScrollBox1CalcContentBounds(Sender: TObject; var ContentBounds: TRectF);
begin
  // ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
  if FNeedOffset and (FKBBounds.Top > 0) then
  begin
    ContentBounds.Bottom:= System.Math.Max(ContentBounds.Bottom, 2 * ClientHeight - FKBBounds.Top);
  end;
end;

procedure TMainForm._RestorePosition;
begin
  // ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
  VertScrollBox1.ViewportPosition:= PointF(VertScrollBox1.ViewportPosition.X, 0);
  MainLayout1.Align := TAlignLayout.Client;
  VertScrollBox1.RealignContent;
end;

procedure TMainForm._UpdateKBBounds;
var
  LFocused: TControl;
  LFocusRect: TRectF;
begin
  // ����Ű���尡 Edit ������ �ʰ� �ϱ����� ��
  FNeedOffset:= False;
  if Assigned(Focused) then
  begin
    LFocused:= TControl(Focused.GetObject);
    LFocusRect:= LFocused.AbsoluteRect;
    LFocusRect.Offset(VertScrollBox1.ViewportPosition);
    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and (LFocusRect.Bottom > FKBBounds.Top) then
    begin
      FNeedOffset:= True;
      MainLayout1.Align:= TAlignLayout.Horizontal;
      VertScrollBox1.RealignContent;
      Application.ProcessMessages;
      VertScrollBox1.ViewportPosition:= PointF(VertScrollBox1.ViewportPosition.X, LFocusRect.Bottom - FKBBounds.Top);
    end;
  end;
  if not FNeedOffset then _RestorePosition;
end;

end.

