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

  // 가상키보드가 Win32, iOS and Android에서 항상 자동으로 나타나도록 한다
  VKAutoShowMode:= TVKAutoShowMode.Always;

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
