program MagicSora;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm1 in 'MainForm1.pas' {MainForm},
  Client1 in 'Client1.pas',
  ConfigForm1 in 'ConfigForm1.pas' {ConfigForm},
  UsbLoadForm1 in 'UsbLoadForm1.pas' {UsbLoadForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
