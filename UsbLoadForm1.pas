unit UsbLoadForm1;

{
// Android에는 TOpenDialog가 작동하지 않기 때문에
// 이 기능을 구현하기 위해 이경백이 만든 Unit임
// Windows에서는 그냥 TOpenDialog 사용하면 됨
// 즉, Windows에서는 여기 들어올 일이 없다
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls, System.Actions,
  FMX.ActnList, FMX.TabControl, System.ImageList, FMX.ImgList;

type
  TUsbLoadForm = class(TForm)
    Layout1: TLayout;
    SelectButton: TButton;
    CancelButton: TButton;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    FolderImageList1: TImageList;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    procedure SelectButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LaunchUsbFolder(Folder: string='');
    procedure AddListItem(FullPathName: string; Kind: integer);
  end;

var
  UsbLoadForm: TUsbLoadForm;

implementation

{$R *.fmx}

uses MainForm1, System.IOUtils, ConfigForm1;

const
  {$IFDEF ANDROID}
  // USB 폴더는 /storage/sdcard0/usb/로 시작함
  USBROOT = '/storage/sdcard0/usb/';
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  // USB 폴더는 F:\로 시작함 (Test용)
  USBROOT = 'F:\';
  {$ENDIF}

procedure TUsbLoadForm.LaunchUsbFolder(Folder: string);
var
  i: integer;
  s: string;
  LList: TStringDynArray;
  st: TStringList;

begin
  // Folder가 ''이면 USBROOT를 탐색
  if Folder = '' then Folder:= USBROOT;

  // ListBox를 초기화후 새로 시작
  ListBox1.Items.Clear;

  // -------------------------------------------------
  // 폴더가 존재하는지 검사
  if not TDirectory.Exists(Folder) then
  begin
    MainForm.ToastMessage('USB 메모리가 없습니다.');
    exit;
  end;

  // 상위 폴더로 갈 수 있는 item 추가
  if Folder <> USBROOT then
  begin
    s:= TDirectory.GetParent(Folder);
    AddListItem(s, 0);
  end;

  // -------------------------------------------------
  try
    // USB의 전체 목록을 가져온다
    // LList:= TDirectory.GetFileSystemEntries(Folder);
    // USB의 Folder 목록을 가져온다
    LList:= TDirectory.GetDirectories(Folder);
  except
    MainForm.ToastMessage('USB 메모리를 꽂아 주세요.');
  end;

  // LList 결과를 ListBox에 집어넣기 전에 Sort해 준다
  st:= TStringList.Create;
  for i:= 1 to Length(LList) do st.Add(LList[i-1]);
  st.Sort;

  // 결과 출력
  for i:= 1 to st.Count do
  begin
    // st[i-1] = FullPathName, 1 = Folder
    AddListItem(st[i-1], 1);
  end;
  st.Free;

  // -------------------------------------------------
  try
    // USB의 File 목록을 가져온다 (ini 파일만)
    LList:= TDirectory.GetFiles(Folder, '*.ini');
  except
    MainForm.ToastMessage('USB 메모리를 꽂아 주세요.');
  end;

  // LList 결과를 ListBox에 집어넣기 전에 Sort해 준다
  st:= TStringList.Create;
  for i:= 1 to Length(LList) do st.Add(LList[i-1]);
  st.Sort;

  // 결과 출력
  for i:= 1 to st.Count do
  begin
    // st[i-1] = FullPathName, 2 = File
    AddListItem(st[i-1], 2);
  end;
  st.Free;

  // 선택은 하지 않는다
  ListBox1.ItemIndex:= -1;
  SelectButton.Enabled:= False;
end;

procedure TUsbLoadForm.AddListItem(FullPathName: string; Kind: integer);
var
  item: TListBoxItem;
begin
  item:= TListBoxItem.Create(ListBox1);

  // 전체경로는 TagString에 보관, 출력은 전체경로 제외
  item.TagString:= FullPathName;
  if Kind = 0 then item.Text:= '상위 폴더'
  else item.Text:= ExtractFileName(FullPathName);

  // Font 크기를 좀 크게 출력
  item.TextSettings.Font.Size:= 24;
  item.StyledSettings:= item.StyledSettings - [TStyledSetting.Size];
  item.Height:= 54;

  // Folder 또는 File임을 표시하고 집어넣는다
  item.ImageIndex:= Kind;
  item.Tag:= Kind;
  ListBox1.AddObject(item);
end;

procedure TUsbLoadForm.ListBox1Click(Sender: TObject);
var
  item: TListBoxItem;
begin
  SelectButton.Enabled:= False;

  // 상위폴더, 일반폴더, 파일 순으로 처리
  item:= ListBox1.Selected;
  if item = nil then exit;

  // 상위폴더 or 일반폴더 클릭시
  if item.Tag <= 1 then
  begin
    // TagString에 저장해 놓은 FullPathName 폴더를 넘겨주어 탐색한다
    LaunchUsbFolder(item.TagString);
  end

  // 파일 클릭시: 여기서는 할일이 없다
  // ItemIndex가 자동으로 바뀌어 준다
  else if item.Tag = 2 then
    SelectButton.Enabled:= True;
end;

procedure TUsbLoadForm.SelectButtonClick(Sender: TObject);
var
  AFileName: string;
  item: TListBoxItem;
begin
  // 선택이 안돼 있으면 나간다
  item:= ListBox1.Selected;
  if item = nil then exit;

  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);

  // 선택된 File이 있으면 ConfigForm에서 불러온다
  // 아래는 UsbFileName 이라는 property 사용할 때의 모습 (지금은 삭제)
  // if UsbFileName <> '' then ConfigForm.LoadUsbFile(UsbFileName);

  {
  // 위에서 item <> nil 이므로 아래처럼 중복 검사할 필요는 없음
  if ListBox1.Count > 0 then
  if ListBox1.ItemIndex >= 0 then
  begin
    AFileName:= ListBox1.Selected.TagString;
    ConfigForm.LoadUsbFile(AFileName);
  end;
  }

  // 실제 FullPathName은 TagString에 있으므로 그냥 열면 된다
  AFileName:= item.TagString;
  ConfigForm.LoadUsbFile(AFileName);
end;

procedure TUsbLoadForm.CancelButtonClick(Sender: TObject);
begin
  // 선택은 하지 않는다
  ListBox1.ItemIndex:= -1;

  // 물어보지 않고 바로 나간다
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);
end;

end.

