unit ConfigForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls;

type
  TConfigForm = class(TForm)
    Layout1: TLayout;
    SaveButton: TButton;
    RevertButton: TButton;
    CancelButton: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure SaveButtonClick(Sender: TObject);
    procedure RevertButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
    // FKBBounds: TRectF;
  public
    { Public declarations }
    KBVisible: boolean;
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
  // ���� �ʱ�ȭ
  KBVisible:= false;

  // ���� 1��° �����: Memo1�� �ִ� �⺻������ ini ���Ϸ� �ѹ� ������ �ش�
  IniFileName:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'MagicSora.ini');
  if not FileExists(IniFileName) then Memo1.Lines.SaveToFile(IniFileName);

  // IniFileName ����� ����
  // ShowMessage('IniFileName = ' + FIniFileName);
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

  {
  FKBBounds:= TRectF.Create(Bounds);
  FKBBounds.TopLeft:= ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight:= ScreenToClient(FKBBounds.BottomRight);
  Memo1.Lines.Add('ShownF: ' + RectFToStr(FKBBounds));
  // FKBBounds = ���� (0, 605, 600, 936) / ���� (0, 272, 961, 575)
  }
end;

procedure TConfigForm.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  // ����Ű���� �������� ��
  KBVisible:= False;
  // Memo1.Lines.Add('Hidden: ' + RectToStr(Bounds));
  // Bounds = ���� (0, 936, 600, 961) / ���� (0, 576, 961, 600)

  // Memo�� ���� ũ�⸦ �����Ѵ�
  Memo1.Align:= TAlignLayout.Client;

  {
  FKBBounds:= TRectF.Create(Bounds);
  FKBBounds.TopLeft:= ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight:= ScreenToClient(FKBBounds.BottomRight);
  Memo1.Lines.Add('HiddenF: ' + RectFToStr(FKBBounds));
  // FKBBounds = ���� (0, 911, 600, 936) / ���� (0, 551, 961, 575)
  }
end;

procedure TConfigForm.LoadIniFile;
begin
  // Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(IniFileName);
end;

procedure TConfigForm.SaveButtonClick(Sender: TObject);
begin
  // Save => ����� Goto Main
  MessageDlg('Save and exit ?',
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

