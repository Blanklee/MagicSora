unit ConfigForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.TabControl;

type
  TConfigForm = class(TForm)
    Layout1: TLayout;
    ApplyButton: TButton;
    RevertButton: TButton;
    CancelButton: TButton;
    Memo1: TMemo;
    LoadButton: TButton;
    SaveButton: TButton;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure RevertButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
    FUsbFileName: string;
  public
    { Public declarations }
    KBVisible: boolean;
    procedure LoadIniFile;
    procedure LoadUsbFile(AFileName: string);
  end;

var
  ConfigForm: TConfigForm;
  IniFileName: string;

implementation

{$R *.fmx}

uses
  MainForm1, System.IOUtils, System.IniFiles, UsbLoadForm1;

const
  {$IFDEF ANDROID}
  USB1 = 'USB';
  USB2 = 'USB 메모리';
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  USB1 = '파일';
  USB2 = '읽어온 파일';
  {$ENDIF}

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  // 변수 초기화
  KBVisible:= false;
  FUsbFileName:= '';

  // 최초 1번째 실행시: Memo1에 있는 기본내용을 ini 파일로 한번 저장해 준다
  IniFileName:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'MagicSora.ini');
  if not TFile.Exists(IniFileName) then Memo1.Lines.SaveToFile(IniFileName);

  // IniFileName 출력해 본다
  // MainForm.ToastMessage('IniFileName = ' + FIniFileName);
  // Windows: C:\Users\blank\Documents
  // Android: /data/data/com.nawoo.MagicPoolMobile/files/MagicSora.ini
end;

function RectToStr(R: TRect): string;
begin
  Result:= '(' + inttostr(R.Left) + ', ' + inttostr(R.Top) + ', ' + inttostr(R.Right) + ', ' + inttostr(R.Bottom) + ')';
end;

function RectFToStr(R: TRectF): string;
begin
  Result:= '(' + FloatToStr(R.Left) + ', ' + FloatToStr(R.Top) + ', ' + FloatToStr(R.Right) + ', ' + FloatToStr(R.Bottom) + ')';
end;

procedure TConfigForm.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  // 가상키보드 나타났을 때
  KBVisible:= True;
  // Memo1.Lines.Add('Shown: ' + RectToStr(Bounds));
  // Bounds = 세로 (0, 630, 600, 961) / 가로 (0, 297, 961, 600)

  // Memo의 세로 크기를 줄여준다
  Memo1.Align:= TAlignLayout.Top;
  Memo1.Height:= Bounds.Top - 56;

  // 커서 위치로 자동 스크롤
  Memo1.SelStart:= Memo1.SelStart;
end;

procedure TConfigForm.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  // 가상키보드 숨겨졌을 때
  KBVisible:= False;
  // Memo1.Lines.Add('Hidden: ' + RectToStr(Bounds));
  // Bounds = 세로 (0, 936, 600, 961) / 가로 (0, 576, 961, 600)

  // Memo의 세로 크기를 복원한다
  Memo1.Align:= TAlignLayout.Client;
end;

procedure TConfigForm.LoadIniFile;
begin
  // Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(IniFileName);

  // 이제 USB로 Save는 할 수 없다
  SaveButton.Enabled:= False;
  FUsbFileName:= '';
end;

procedure TConfigForm.LoadUsbFile(AFileName: string);
begin
  // 파일이 존재하는지 검사
  if not TFile.Exists(AFileName) then
  begin
    MainForm.ToastMessage('파일을 읽을 수 없습니다.');
    exit;
  end;

  // 파일이름은 저장해 두고
  FUsbFileName:= AFileName;

  // Memo로 파일내용을 읽어들인다
  Memo1.Lines.LoadFromFile(AFileName);

  // 이제 USB로 Save 할 수 있다
  SaveButton.Enabled:= True;

  // 화면에 안내문 출력
  MainForm.ToastMessage(USB1 + '에서 설정을 읽어왔습니다.');
end;

procedure TConfigForm.LoadButtonClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
  // Android 에서는 TOpenDialog가 동작하지 않으므로 UsbLoadForm을 띄워준다
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_UsbLoad;
  ChangeTabAction2.ExecuteTarget(Self);

  // USB 폴더에 있는 내용을 가져와 보여준다
  UsbLoadForm.LaunchUsbFolder;
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  // Windows 에서는 그냥 TOpenDialog를 사용하면 된다
  if OpenDialog1.Execute then
  begin
    // ini 파일을 Open한다
    // Android 에서도 결국 아래함수 호출한다
    LoadUsbFile(OpenDialog1.FileName);
  end;
  {$ENDIF}
end;

procedure TConfigForm.SaveButtonClick(Sender: TObject);
begin
  // USB에 ini파일 저장
  // 파일 이름은 아까 LoadUsbFile 함수에서 저장해 놓은것 사용
  MessageDlg(USB2 + '에 현재 내용을 저장할까요 ?',
  TMsgDlgType.mtConfirmation, mbOkCancel, 0,
  procedure(const AResult: TModalResult)
  begin
    if (AResult = mrOk) then
    begin
      // 문제점 : Load 하지 않았는데 먼저 Save 하는 경우, 또는 파일이름이 아직 없으면 저장이 안돼야 함
      if FUsbFileName = ''
      then MainForm.ToastMessage(USB1 + '에서 아직 읽지 않았습니다.')
      // 문제점 : 저장할 파일이름 선택할 수 있게 할것
      // USB 메모리에 그대로 저장. 현재는 그냥 덮어쓴다.
      else begin
        Memo1.Lines.SaveToFile(FUsbFileName);
        MainForm.ToastMessage(USB1 + '로 저장하였습니다.');
      end;
    end;
  end);
end;

procedure TConfigForm.ApplyButtonClick(Sender: TObject);
begin
  // Save => 물어보고 Goto Main
  MessageDlg('포트 목록에 반영할까요 ?',
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
        MainForm.ToastMessage('원상복구 되었습니다.');
      end;
    end);
end;

procedure TConfigForm.CancelButtonClick(Sender: TObject);
begin
  // Cancel => 물어보고 Goto Main
  MessageDlg('취소하고 원래의 포트 목록으로 돌아갑니다.',
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

