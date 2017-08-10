unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,jiabinsocks5proxy;

type
  TForm1 = class(TForm)
    EUser: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Epass: TEdit;
    Label3: TLabel;
    EPort: TEdit;
    Button1: TButton;
    taoshi: TLabel;
    procedure EPortKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  ProxyServer:TSocks5Proxykk;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
     if (button1.Caption='run') then
        begin
           ProxyServer:=TSocks5Proxykk.Create(taoshi);
            ProxyServer.User:=Euser.Text;
             ProxyServer.Pass:=Epass.Text;
             ProxyServer.Port:=strtoint(Eport.text);
             ProxyServer.StartServer;
            button1.Caption:='stop';
        end else
        begin
           ProxyServer.Free;
           button1.Caption:='run';
        end;

end;

procedure TForm1.EPortKeyPress(Sender: TObject; var Key: Char);
begin

      if not (key in ['0'..'9','.',#8]) then

      begin

        key:=#0;

        Messagebeep(0);

      end;

end;

end.
