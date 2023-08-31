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
// property UsbFileName 사용안함
function TUsbLoadForm.GetUsbFileName: string;
begin
  Result:= '';

  // Item에서 선택된 항목의 String을 Return한다
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
    // USB 폴더는 /storage/sdcard0/usb/로 시작함
    Folder:= '/storage/sdcard0/usb/';
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    // USB 폴더는 F:\로 시작함
    Folder:= 'F:\';
    {$ENDIF}

    // USB 폴더의 목록을 가져온다
    LList:= TDirectory.GetFileSystemEntries(Folder);
  except
    MainForm.ToastMessage('USB 메모리를 꽂아 주세요.');
  end;

  // 결과 출력
  for i:= 1 to Length(LList) do
    ListBox1.Items.Add(LList[i-1]);

  // 선택은 하지 않는다
  ListBox1.ItemIndex:= -1;
end;

procedure TUsbLoadForm.ListBox1Click(Sender: TObject);
begin
  // 여기서는 할 일이 없다
  // ItemIndex가 자동으로 바뀌어 준다
end;

procedure TUsbLoadForm.SelectButtonClick(Sender: TObject);
var
  AFileName: string;
begin
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);

  // 선택된 File이 있으면 ConfigForm에서 불러온다
  // 아래는 UsbFileName 이라는 property 사용할 때의 모습 (지금은 삭제)
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
  // 선택은 하지 않는다
  ListBox1.ItemIndex:= -1;

  // 물어보지 않고 바로 나간다
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_Config;
  ChangeTabAction1.ExecuteTarget(Self);
end;

end.

