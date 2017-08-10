unit Unit2;

interface
uses
  Winsock, Classes, Sysutils, WinTypes, Messages, Forms;
  
type
 
  UDPSockError = class(Exception);

   {Event Handlers}

  TOnErrorEvent = procedure(Sender: TComponent; errno: word; Errmsg: string) of object;
  TOnStatus = procedure(Sender: TComponent; status: string) of object;
  TOnReceive = procedure(Sender: TComponent; NumberBytes: Integer; FromIP: string; Port: integer) of object;
  THandlerEvent = procedure(var handled: boolean) of object;
  TBuffInvalid = procedure(var handled: boolean; var Buff: array of char; var length: integer) of object;
  TStreamInvalid = procedure(var handled: boolean; Stream: TStream) of object;

implementation

end.
