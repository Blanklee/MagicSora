unit ConfigForm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Edit;

type
  TConfigForm = class(TForm)
    Layout1: TLayout;
    SaveButton: TButton;
    RevertButton: TButton;
    CancelButton: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure RevertButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
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
  // ���� 1��° �����: Memo1�� �ִ� �⺻������ ini ���Ϸ� �ѹ� ������ �ش�
  IniFileName:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'MagicSora.ini');
  if not FileExists(IniFileName) then Memo1.Lines.SaveToFile(IniFileName);

  // IniFileName ����� ����
  // ShowMessage('IniFileName = ' + FIniFileName);
  // Windows: C:\Users\blank\Documents
  // Android: /data/data/com.nawoo.MagicPoolMobile/files/MagicSora.ini
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

