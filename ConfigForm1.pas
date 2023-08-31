unit ConfigForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Edit,
  Androidapi.JNI.Interfaces, System.Messaging, FMX.Platform.Android,
  Androidapi.Helpers, Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText;

type
  TConfigForm = class(TForm)
    Layout1: TLayout;
    LoadButton: TButton;
    SaveButton: TButton;
    RevertButton: TButton;
    CancelButton: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure RevertButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
    const ScanRequestCode = 0;
    var FMessageSubscriptionID: Integer;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
  public
    { Public declarations }
    procedure LoadIniFile;
  end;

var
  ConfigForm: TConfigForm;
  IniFileName: string;

implementation

{$R *.fmx}

uses MainForm1, System.IOUtils, System.IniFiles;

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  // 최초 1번째 실행시: Memo1에 있는 기본내용을 ini 파일로 한번 저장해 준다
  IniFileName:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'MagicSora.ini');
  if not FileExists(IniFileName) then Memo1.Lines.SaveToFile(IniFileName);

  // IniFileName 출력해 본다
  // ShowMessage('IniFileName = ' + FIniFileName);
  // Windows: C:\Users\blank\Documents
  // Android: /data/data/com.nawoo.MagicPoolMobile/files/MagicSora.ini
end;

procedure TConfigForm.LoadIniFile;
begin
  // Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(IniFileName);
end;




// ------------------------------------------------------------------------------------------
// 여기서부터 OpenDialog 구현

procedure TConfigForm.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode, TMessageResultNotification(M).ResultCode,
    TMessageResultNotification(M).Value);
end;

function TConfigForm.OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
var
  filename : string;
begin
  Result := False;

  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, FMessageSubscriptionID);
  FMessageSubscriptionID := 0;

  // For more info see https://github.com/zxing/zxing/wiki/Scanning-Via-Intent
  if RequestCode = ScanRequestCode then
  begin
    if ResultCode = TJActivity.JavaClass.RESULT_OK then
    begin
      if Assigned(Data) then
      begin
        filename := JStringToString(Data.getStringExtra(StringToJString('RESULT_PATH')));
        // 설정 파일로부터 내용을 읽어들인다
        Memo1.Lines.LoadFromFile(filename);
        //Toast(Format('Found %s format barcode:'#10'%s', [ScanFormat, ScanContent]), LongToast);
      end;
    end
    else if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then
    begin
      //Toast('You cancelled the scan', ShortToast);
    end;
    Result := True;
  end;
end;

procedure TConfigForm.LoadButtonClick(Sender: TObject);
var
  Intent: JIntent; // JFileDialog;
begin
  FMessageSubscriptionID := TMessageManager.DefaultManager.SubscribeToMessage
    (TMessageResultNotification, HandleActivityMessage);

  Intent := TJIntent.JavaClass.init;
  Intent.setClassName(SharedActivityContext, StringToJString('com.lamerman.FileDialog'));
  SharedActivity.startActivityForResult(Intent, 0);
end;

// 여기까지 OpenDialog 구현
// ------------------------------------------------------------------------------------------




procedure TConfigForm.SaveButtonClick(Sender: TObject);
begin
  // Save => 물어보고 Goto Main
  MessageDlg('Save and exit ?',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        // 저장하고 반영한다
        Memo1.Lines.SaveToFile(IniFileName);

        // Goto Main, 1 = 변경사항 반영한다
        MainForm.GotoMainTab(1);
      end;
    end);
end;

procedure TConfigForm.RevertButtonClick(Sender: TObject);
begin
  // Revert => 물어보고 원상복구
  MessageDlg('변경사항을 원상복구 할까요 ?',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        LoadIniFile;
      end;
    end);
end;

procedure TConfigForm.CancelButtonClick(Sender: TObject);
begin
  // Cancel => 물어보고 Goto Main
  MessageDlg('Cancel and exit ?'#10#10'변경사항은 모두 원상복구 됩니다.',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        // Goto Main, 0 = 아무것도 안함
        MainForm.GotoMainTab(0);
      end;
    end);
end;

end.

