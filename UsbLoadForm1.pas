unit UsbLoadForm1;

{
// Android���� TOpenDialog�� �۵����� �ʱ� ������
// �� ����� �����ϱ� ���� �̰���� ���� Unit��
// Windows������ �׳� TOpenDialog ����ϸ� ��
// ��, Windows������ ���� ���� ���� ����
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
  // USB ������ /storage/sdcard0/usb/�� ������
  USBROOT = '/storage/sdcard0/usb/';
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  // USB ������ F:\�� ������ (Test��)
  USBROOT = 'F:\';
  {$ENDIF}

procedure TUsbLoadForm.LaunchUsbFolder(Folder: string);
var
  i: integer;
  s: string;
  LList: TStringDynArray;
  st: TStringList;

begin
  // Folder�� ''�̸� USBROOT�� Ž��
  if Folder = '' then Folder:= USBROOT;

  // ListBox�� �ʱ�ȭ�� ���� ����
  ListBox1.Items.Clear;

  // -------------------------------------------------
  // ������ �����ϴ��� �˻�
  if not TDirectory.Exists(Folder) then
  begin
    MainForm.ToastMessage('USB �޸𸮰� �����ϴ�.');
    exit;
  end;

  // ���� ������ �� �� �ִ� item �߰�
  if Folder <> USBROOT then
  begin
    s:= TDirectory.GetParent(Folder);
    AddListItem(s, 0);
  end;

  // -------------------------------------------------
  try
    // USB�� ��ü ����� �����´�
    // LList:= TDirectory.GetFileSystemEntries(Folder);
    // USB�� Folder ����� �����´�
    LList:= TDirectory.GetDirectories(Folder);
  except
    MainForm.ToastMessage('USB �޸𸮸� �Ⱦ� �ּ���.');
  end;

  // LList ����� ListBox�� ����ֱ� ���� Sort�� �ش�
  st:= TStringList.Create;
  for i:= 1 to Length(LList) do st.Add(LList[i-1]);
  st.Sort;

  // ��� ���
  for i:= 1 to st.Count do
  begin
    // st[i-1] = FullPathName, 1 = Folder
    AddListItem(st[i-1], 1);
  end;
  st.Free;

  // -------------------------------------------------
  try
    // USB�� File ����� �����´� (ini ���ϸ�)
    LList:= TDirectory.GetFiles(Folder, '*.ini');
  except
    MainForm.ToastMessage('USB �޸𸮸� �Ⱦ� �ּ���.');
  end;

  // LList ����� ListBox�� ����ֱ� ���� Sort�� �ش�
  st:= TStringList.Create;
  for i:= 1 to Length(LList) do st.Add(LList[i-1]);
  st.Sort;

  // ��� ���
  for i:= 1 to st.Count do
  begin
    // st[i-1] = FullPathName, 2 = File
    AddListItem(st[i-1], 2);
  end;
  st.Free;

  // ������ ���� �ʴ´�
  ListBox1.ItemIndex:= -1;
  SelectButton.Enabled:= False;
end;

procedure TUsbLoadForm.AddListItem(FullPathName: string; Kind: integer);
var
  item: TListBoxItem;
begin
  item:= TListBoxItem.Create(ListBox1);

  // ��ü��δ� TagString�� ����, ����� ��ü��� ����
  item.TagString:= FullPathName;
  if Kind = 0 then item.Text:= '���� ����'
  else item.Text:= ExtractFileName(FullPathName);

  // Font ũ�⸦ �� ũ�� ���
  item.TextSettings.Font.Size:= 24;
  item.StyledSettings:= item.StyledSettings - [TStyledSetting.Size];
  item.Height:= 54;

  // Folder �Ǵ� File���� ǥ���ϰ� ����ִ´�
  item.ImageIndex:= Kind;
  item.Tag:= Kind;
  ListBox1.AddObject(item);
end;

procedure TUsbLoadForm.ListBox1Click(Sender: TObject);
var
  item: TListBoxItem;
begin
  SelectButton.Enabled:= False;

  // ��������, �Ϲ�����, ���� ������ ó��
  item:= ListBox1.Selected;
  if item = nil then exit;

  // �������� or �Ϲ����� Ŭ����
  if item.Tag <= 1 then
  begin
    // TagString�� ������ ���� FullPathName ������ �Ѱ��־� Ž���Ѵ�
    LaunchUsbFolder(item.TagString);
  end

  // ���� Ŭ����: ���⼭�� ������ ����
  // ItemIndex�� �ڵ����� �ٲ�� �ش�
  else if item.Tag = 2 then
    SelectButton.Enabled:= True;
end;

procedure TUsbLoadForm.SelectButtonClick(Sender: TObject);
var
  AFileName: string;
  item: TListBoxItem;
begin
  // ������ �ȵ� ������ ������
  item:= ListBox1.Selected;
  if item = nil then exit;

  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);

  // ���õ� File�� ������ ConfigForm���� �ҷ��´�
  // �Ʒ��� UsbFileName �̶�� property ����� ���� ��� (������ ����)
  // if UsbFileName <> '' then ConfigForm.LoadUsbFile(UsbFileName);

  {
  // ������ item <> nil �̹Ƿ� �Ʒ�ó�� �ߺ� �˻��� �ʿ�� ����
  if ListBox1.Count > 0 then
  if ListBox1.ItemIndex >= 0 then
  begin
    AFileName:= ListBox1.Selected.TagString;
    ConfigForm.LoadUsbFile(AFileName);
  end;
  }

  // ���� FullPathName�� TagString�� �����Ƿ� �׳� ���� �ȴ�
  AFileName:= item.TagString;
  ConfigForm.LoadUsbFile(AFileName);
end;

procedure TUsbLoadForm.CancelButtonClick(Sender: TObject);
begin
  // ������ ���� �ʴ´�
  ListBox1.ItemIndex:= -1;

  // ����� �ʰ� �ٷ� ������
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);
end;

end.

