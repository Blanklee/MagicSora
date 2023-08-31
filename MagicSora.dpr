program MagicSora;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm1 in 'MainForm1.pas' {Form1},
  Client1 in 'Client1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
