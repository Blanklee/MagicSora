program MagicSora;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Types,
  MainForm1 in 'MainForm1.pas' {MainForm},
  Client1 in 'Client1.pas',
  ConfigForm1 in 'ConfigForm1.pas' {ConfigForm},
  Androidapi.JNI.Interfaces in 'Androidapi.JNI.Interfaces.pas';

{$R *.res}

begin
  Application.Initialize;

  // ����Ű���尡 Win32, iOS and Android���� �׻� �ڵ����� ��Ÿ������ �Ѵ�
  VKAutoShowMode:= TVKAutoShowMode.Always;

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
