unit UsbLoadForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls, System.Actions,
  FMX.ActnList, FMX.TabControl;

type
  TUsbLoadForm = class(TForm)
    Layout1: TLayout;
    ListBox1: TListBox;
    SelectButton: TButton;
    CancelButton: TButton;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    procedure SelectButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    // function GetUsbFileName: string;
    { Private declarations }
  public
    { Public declarations }
    procedure LaunchUsbFolder;
    // property UsbFileName: string read GetUsbFileName;
  end;

var
  UsbLoadForm: TUsbLoadForm;

implementation

{$R *.fmx}

uses MainForm1, System.IOUtils, ConfigForm1;

{
// property UsbFileName ������
function TUsbLoadForm.GetUsbFileName: string;
begin
  Result:= '';

  // Item���� ���õ� �׸��� String�� Return�Ѵ�
  if ListBox1.Count > 0 then
  if ListBox1.ItemIndex >= 0 then
  Result:= ListBox1.Items[ListBox1.ItemIndex];
end;
}

procedure TUsbLoadForm.LaunchUsbFolder;
var
  i: integer;
  Folder: string;
  LList: TStringDynArray;
begin
  ListBox1.Items.Clear;

  try
    {$IFDEF ANDROID}
    // USB ������ /storage/sdcard0/usb/�� ������
    Folder:= '/storage/sdcard0/usb/';
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    // USB ������ F:\�� ������
    Folder:= 'F:\';
    {$ENDIF}

    // USB ������ ����� �����´�
    LList:= TDirectory.GetFileSystemEntries(Folder);
  except
    MainForm.ToastMessage('USB �޸𸮸� �Ⱦ� �ּ���.');
  end;

  // ��� ���
  for i:= 1 to Length(LList) do
    ListBox1.Items.Add(LList[i-1]);

  // ������ ���� �ʴ´�
  ListBox1.ItemIndex:= -1;
end;

procedure TUsbLoadForm.ListBox1Click(Sender: TObject);
begin
  // ���⼭�� �� ���� ����
  // ItemIndex�� �ڵ����� �ٲ�� �ش�
end;

procedure TUsbLoadForm.SelectButtonClick(Sender: TObject);
var
  AFileName: string;
begin
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);

  // ���õ� File�� ������ ConfigForm���� �ҷ��´�
  // �Ʒ��� UsbFileName �̶�� property ����� ���� ��� (������ ����)
  // if UsbFileName <> '' then ConfigForm.LoadUsbFile(UsbFileName);

  if ListBox1.Count > 0 then
  if ListBox1.ItemIndex >= 0 then
  begin
    AFileName:= ListBox1.Items[ListBox1.ItemIndex];
    ConfigForm.LoadUsbFile(AFileName);
  end;
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

