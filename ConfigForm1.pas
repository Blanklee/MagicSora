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
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure ApplyButtonClick(Sender: TObject);
    procedure RevertButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
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

uses MainForm1, System.IOUtils, System.IniFiles, UsbLoadForm1;

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  // ���� �ʱ�ȭ
  KBVisible:= false;
  FUsbFileName:= '';

  // ���� 1��° �����: Memo1�� �ִ� �⺻������ ini ���Ϸ� �ѹ� ������ �ش�
  IniFileName:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'MagicSora.ini');
  if not FileExists(IniFileName) then Memo1.Lines.SaveToFile(IniFileName);

  // IniFileName ����� ����
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
  // ����Ű���� ��Ÿ���� ��
  KBVisible:= True;
  // Memo1.Lines.Add('Shown: ' + RectToStr(Bounds));
  // Bounds = ���� (0, 630, 600, 961) / ���� (0, 297, 961, 600)

  // Memo�� ���� ũ�⸦ �ٿ��ش�
  Memo1.Align:= TAlignLayout.Top;
  Memo1.Height:= Bounds.Top - 56;

  // Ŀ�� ��ġ�� �ڵ� ��ũ��
  Memo1.SelStart:= Memo1.SelStart;
end;

procedure TConfigForm.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  // ����Ű���� �������� ��
  KBVisible:= False;
  // Memo1.Lines.Add('Hidden: ' + RectToStr(Bounds));
  // Bounds = ���� (0, 936, 600, 961) / ���� (0, 576, 961, 600)

  // Memo�� ���� ũ�⸦ �����Ѵ�
  Memo1.Align:= TAlignLayout.Client;
end;

procedure TConfigForm.LoadIniFile;
begin
  // Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(IniFileName);

  // ���� USB�� Save�� �� �� ����
  SaveButton.Enabled:= False;
end;

procedure TConfigForm.LoadUsbFile(AFileName: string);
begin
  // �����̸��� ������ �ΰ�
  FUsbFileName:= AFileName;

  // Memo�� ���ϳ����� �о���δ�
  Memo1.Lines.LoadFromFile(AFileName);

  // ���� USB�� Save �� �� �ִ�
  SaveButton.Enabled:= True;

  // ȭ�鿡 �ȳ��� ���
  MainForm.ToastMessage('USB���� ������ �о�Խ��ϴ�.');
end;

procedure TConfigForm.LoadButtonClick(Sender: TObject);
begin
  // MainForm.TabControl1.ActiveTab:= MainForm.TabItem_UsbLoad;
  ChangeTabAction2.ExecuteTarget(Self);

  // USB�κ��� ini���� �б� ����
  UsbLoadForm.LaunchUsbFolder;
end;

procedure TConfigForm.SaveButtonClick(Sender: TObject);
begin
  // USB�� ini���� ����
  // ���� �̸��� �Ʊ� LoadUsbFile �Լ����� ������ ������ ���
  MessageDlg('USB �޸𸮿� ���� ������ �����ұ�� ?',
  TMsgDlgType.mtConfirmation, mbOkCancel, 0,
  procedure(const AResult: TModalResult)
  begin
    if (AResult = mrOk) then
    begin
      // ������ : Load ���� �ʾҴµ� ���� Save �ϴ� ���, �Ǵ� �����̸��� ���� ������ ������ �ȵž� ��
      if FUsbFileName = ''
      then MainForm.ToastMessage('USB���� ���� ���� �ʾҽ��ϴ�.')
      // ������ : ������ �����̸� ������ �� �ְ� �Ұ�
      // USB �޸𸮿� �״�� ����. ����� �׳� �����.
      else begin
        Memo1.Lines.SaveToFile(FUsbFileName);
        MainForm.ToastMessage('USB�� �����Ͽ����ϴ�.');
      end;
    end;
  end);
end;

procedure TConfigForm.ApplyButtonClick(Sender: TObject);
begin
  // Save => ����� Goto Main
  MessageDlg('Apply and exit ?',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        // �����ϰ� �ݿ��Ѵ�
        Memo1.Lines.SaveToFile(IniFileName);

        // Goto Main, 1 = ������� �ݿ��Ѵ�
        MainForm.GotoMainTab(1);
      end;
    end);
end;

procedure TConfigForm.RevertButtonClick(Sender: TObject);
begin
  // Revert => ����� ���󺹱�
  MessageDlg('��������� ���󺹱� �ұ�� ?',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        LoadIniFile;
        MainForm.ToastMessage('���󺹱� �Ǿ����ϴ�.');
      end;
    end);
end;

procedure TConfigForm.CancelButtonClick(Sender: TObject);
begin
  // Cancel => ����� Goto Main
  MessageDlg('Cancel and exit ?'#10#10'��������� ��� ���󺹱� �˴ϴ�.',
    TMsgDlgType.mtConfirmation, mbOkCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrOk) then
      begin
        // Goto Main, 0 = �ƹ��͵� ����
        MainForm.GotoMainTab(0);
      end;
    end);
end;

end.

