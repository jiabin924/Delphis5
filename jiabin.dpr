program jiabin;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  jiaMYNMUDP in 'jiaMYNMUDP.pas',
  jiabinSocks5Proxy in 'jiabinSocks5Proxy.pas',
  Unit2 in 'Unit2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
