unit jiabinSocks5Proxy;
{
Write By Wenjinshan.
}
interface

uses
  Windows, SysUtils, Classes, ExtCtrls, ScktComp, Forms,
  StdCtrls,winsock ,jiaMYNMUDP,math,Dialogs;


const
   //MAXurl=255;
   VER=#5;
   IsServer=$40000000;
   DefaultPort=1080;
   StartPort=4000;
   
type
  PCharArray = ^TCharArray;
  TCharArray = array[0..32767] of Char;

  sessiont_record=record
    Valid:boolean; //是否有效
    Close:boolean;
    step:integer;//连接步骤

    jiabinUdpClient:TMYNMUDP; //客户的udp
    UdpSite:TMYNMUDP; //网站的udp

    TcpSite:TClientSocket; //网站的tcp
    TcpClient:TCustomWinSocket; //客户的tcp

    ListenServer:TServerSocket; //Listen的服务器
    ListenOneThread:TCustomWinSocket;

    LastError:integer;
  end;

  TSocks5Proxykk = class
  private
    ServerSocket2: TServerSocket;
    TimerRefreshjia: TTimer;
    NMUDP1: TMYNMUDP;
    FPort: Integer;
    Fuser: String;
    Fpass: String;
    ttaoshi: TLabel;
    function jiaGetSock5Host(buf:pchar;var p:integer):string;
    procedure jiaDataReceived(Sender: TComponent;
      NumberBytes: Integer; FromIP: String; Port: Integer);  //双方都要自己发给自己判断是否有效
    procedure jiabindPort(jiabinudp:TMYNMUDP;jiabinMyIP:string;var Port:integer);

    procedure ServerSocket2ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket2ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket2ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ServerSocket2ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);

    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject;
       Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
       var ErrorCode: Integer);
    procedure ClientSocket1Read(Sender: TObject;
       Socket: TCustomWinSocket);

    procedure TimerRefreshTimerjia(Sender: TObject);
    procedure jiabinNMUDP1DataReceived(Sender: TComponent; NumberBytes: Integer;
      FromIP: String; Port: Integer);
    procedure ListenServerClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ListenServerClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ListenServerClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ListenServerClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SetPort(const Value: Integer);
    procedure SetUser(const Value: String);
    procedure SetPass(const Value: String);
    { Private declarations }
  public
    property User: String read FUser write SetUser;
    property Pass: String read FPass write SetPass;
    property Port: Integer read FPort write SetPort;
    constructor Create(taoshis:TLabel);
    destructor Destroy; override;
    procedure StopServer;
    procedure StartServer;


  end;

var
    sessiont:array of sessiont_record;
    LastPort:integer;  //最后一个使用的端口

implementation
uses Unit1;
function DwordToStr(Value: dword): string;
var
ResultPtr: PChar;
begin
SetLength(Result, 4);
ResultPtr:=@Result[1];
asm
MOV EAX, [ResultPtr]
MOV EBX, Value
MOV [EAX], EBX end;
end;
function StrToDword(Value: string): dword;
var
ValuePtr: PChar;
begin
ValuePtr:=@Value[1];
asm
MOV EAX, [ValuePtr]
MOV EAX, [EAX]
MOV Result, EAX end;
end;
procedure TSocks5Proxykk.jiabindPort(jiabinudp:TMYNMUDP;jiabinMyIP:string;var Port:integer);
var
   bufj:array[0..3]of char;
   jiabint:dword;
//srt:string;
begin
       //  下面搜索本机有效的udp端口
      jiabinudp.Tag:=0; //无效的
      jiabinudp.RemoteHost:= jiabinMyIP; //自己发给自己
      jiabinudp.OnDataReceived:=jiaDataReceived;

      jiabinudp.LocalPort:=4000;

      jiabinudp.RemotePort:=jiabinudp.LocalPort;

      pinteger(@bufj)^:=jiabinudp.LocalPort;
      jiabinudp.SendBuffer(bufj,sizeof(bufj));
    //gettickcount:=gettickcount;
     // if hh=0 then huu:=0 ;
    // srt:=DwordToStr(gettickcount);
    //  jiabint:=StrToDword(srt);
      jiabint:=gettickcount;
     while (jiabinudp.tag=0)and(gettickcount-jiabint<50) do
       begin
     // hh:=gettickcount;
     // if (hh-jiabint)<50 then
     //  break;
     // huu:=1+4;
      application.ProcessMessages;
       end;


   while  jiabinudp.tag=0 do //端口不合法，改变端口再发
      begin
         jiabinudp.LocalPort:=Port;
        // inc(Port);
         Port:=Port+1;
         if Port=MAXWORD then Port:=StartPort;
        jiabinudp.RemotePort:=jiabinudp.LocalPort;
         pinteger(@bufj)^:=jiabinudp.LocalPort;
         jiabinudp.SendBuffer(bufj,sizeof(bufj));
         jiabint:=gettickcount;
         while (jiabinudp.tag=0)and(gettickcount-jiabint<50)do
           application.ProcessMessages;
      end;
end;

function WordToS(w:word):string;
begin
   setlength(result,sizeof(word));
   pword(@result[1])^:=w;
end;

function LongWordToS(w:Longword):string;
begin
   setlength(result,sizeof(Longword));
   pLongword(@result[1])^:=w;
end;

function CharToAIISC(buf:pchar;len:integer):string;//把字符全用十六进制的"xx "的形式表示出来
var
   i:integer;
begin
  result:='';
  for i:=0 to len-1 do
  begin
     result:=result+format('%2.2X ',[ord(Buf[i])]);
  end;
end;

function CharToString(Buf:pchar;length:integer):string;//char转变成string
var
   s:string;
begin
   setlength(s,length);
   move(Buf[0],s[1],length); //不能用strcopy
   result:=s;
end;

procedure TSocks5Proxykk.jiaDataReceived(Sender: TComponent;
  NumberBytes: Integer; FromIP: String; Port: Integer);
var
   buf:array[0..3]of char;
begin
  if NumberBytes<>sizeof(buf) then exit;
  (Sender as TMYNMUDP).ReadBuffer(buf, NumberBytes);
  if pinteger(@buf)^=Port then (Sender as TMYNMUDP).tag:=1; //有效的
end;
{客户发信息过来时}
procedure TSocks5Proxykk.ServerSocket2ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
const
   MaxBuf=10240;
var
   io,p,ReceiveBufLength:integer;
   sendtext:string;
   ReceiveBuf:array[0..MaxBuf-1]of char;
   siteHost:string;
   IP:string;
   user,pass:string;
   hjiaTMYNMUDP:TMYNMUDP;
begin
   io:=integer(Socket.data);//会话指针
   ReceiveBufLength:=min(MaxBuf,socket.ReceiveLength);
   socket.ReceiveBuf(ReceiveBuf, ReceiveBufLength);

   if (sessiont[io].step=0) then
   begin
      if (plongword(@ReceiveBuf)^ and $00FFFFFF = $00000105)or
         (plongword(@ReceiveBuf)^ and $00FFFFFF = $00000205) then //客户端询问代理端是否可以无密码连接
      begin
         //告诉客户端可以连接
         if Fuser='' then
         begin
            sendtext:=VER+#0;
            inc(sessiont[io].step,2);
            Socket.SendText(sendtext);
           // ttaoshi.Caption:='lianjie';
         ;end;
          if Fuser<>'' then
         begin     //有密码
           sendtext:=VER+#2;
            inc(sessiont[io].step);
            Socket.SendText(sendtext) ;
         end;
         {　　
         >> '00' 无验证需求
       　>> '01' 通用安全服务应用程序接口(GSSAPI)
     　　>> '02' 用户名/密码(USERNAME/PASSWORD)
     　　>> '03' 至 X'7F' IANA 分配(IANA ASSIGNED)
     　　>> '80' 至 X'FE' 私人方法保留(RESERVED FOR PRIVATE METHODS)
       　>> 'FF' 无可接受方法(NO ACCEPTABLE METHODS) }
      end
      else if (plongword(@ReceiveBuf)^ and $00FFFFFF = $00020105)or
              (plongword(@ReceiveBuf)^ and $00FFFFFF = $00020205) then //客户端询问代理端是否可以有密码连接
      begin
      if Fuser<>'' then
         begin     //有密码
           sendtext:=VER+#2;
            inc(sessiont[io].step);
            Socket.SendText(sendtext) ;
         end;
      end;
   end
   else if (sessiont[io].step=1) then
   begin
      if(ReceiveBufLength<3)then exit;
      if(ReceiveBuf[0]=#1)then
      begin
         p:=1;
         setlength(user,ord(ReceiveBuf[p]));
         move(ReceiveBuf[p+1],user[1],ord(ReceiveBuf[p]));
         inc(p, ord(ReceiveBuf[p])+1);

         setlength(pass,ord(ReceiveBuf[p]));
         move(ReceiveBuf[p+1],pass[1],ord(ReceiveBuf[p]));
         if(user=Fuser)and(pass=Fpass)then
         begin
            inc(sessiont[io].step);
            Socket.SendText(#1#0);
         end
         else begin
            sessiont[io].step:=0;
            Socket.SendText(#1#$2);
         end;
      end;
   end
   else if (sessiont[io].step=2) then
   begin
      if(ReceiveBufLength<4)then exit;
      case plongword(@ReceiveBuf)^ and $00FFFFFF of
      $00000305:

       begin //客户端把自己的udp端口告诉代理端
       //showmessage('udp');
      // ttaoshi.Caption:='udp';
         p:=3;
         siteHost:=jiaGetSock5Host(@ReceiveBuf,p);
         if siteHost='' then
         begin
           sessiont[io].jiabinudpClient:=TMYNMUDP.Create(nil); //生成一个新的udp，用于以后连接客户
           hjiaTMYNMUDP:=TMYNMUDP.Create(nil);
           hjiaTMYNMUDP:=sessiont[io].jiabinudpClient;
          // ttaoshi.Caption:='udp';
           jiabindPort(sessiont[io].jiabinudpClient,ServerSocket2.Socket.LocalHost,Lastport);
          // ttaoshi.Caption:='udp';
           sessiont[io].jiabinudpClient.Tag:=io; //会话指针,表示客户
           sessiont[io].jiabinudpClient.OnDataReceived:=jiabinNMUDP1DataReceived;
            sessiont[io].jiabinudpClient.RemotePort:= ntohs( pword(@ReceiveBuf[p])^ );
            sessiont[io].jiabinudpClient.RemoteHost:= string(inet_ntoa(Socket.RemoteAddr.sin_addr));
            inc(p,2);

            sessiont[io].udpSite:=TMYNMUDP.Create(nil); //生成一个新的udp，用于以后连接网站

           jiabindPort(sessiont[io].udpSite,ServerSocket2.Socket.LocalHost,Lastport);

           sessiont[io].udpSite.Tag:=io or IsServer; //会话指   针,IsServer表示网站
           sessiont[io].udpSite.OnDataReceived:=jiabinNMUDP1DataReceived;

            setlength(IP,4);
            plongword(@IP[1])^:=inet_addr(pchar(socket.LocalAddress));
           // ttaoshi.Caption:=sessiont[io].jiabinudpClient.RemoteHost+'udpClient端口'+inttostr(sessiont[io].jiabinudpClient.LocalPort);
            sendtext:=VER+#0#0#1+ IP + WordToS(htons(sessiont[io].jiabinudpClient.LocalPort));//sock5服务器的端口,htons高低位互换

            inc(sessiont[io].step);
            Socket.SendText(sendtext);
         end;
       end;
      $00000105:
       begin //客户端把自己的connect端口告诉代理端
         ttaoshi.Caption:='tcp';
         p:=3;
         siteHost:=jiaGetSock5Host(@ReceiveBuf,p);
         if siteHost<>'' then
         begin
//            session[i].ConnectOrListen:=true; //客户是Connect
            sessiont[io].TcpClient:=socket;
            sessiont[io].TcpSite:=TClientSocket.Create(nil);
            sessiont[io].TcpSite.Host:=siteHost;
            sessiont[io].TcpSite.Port:=ntohs( pword(@ReceiveBuf[p])^ );  //要connect的端口, ntohs高低位互换
            inc(p,2);
            sessiont[io].TcpSite.Tag:=io;
            sessiont[io].TcpSite.OnError:=ClientSocket1Error;
            sessiont[io].TcpSite.OnDisconnect:=ClientSocket1Disconnect;
            sessiont[io].TcpSite.OnRead:=ClientSocket1Read;
            sessiont[io].LastError:=0;
            try
               sessiont[io].TcpSite.Active:=true;
            except
            end;
            while(sessiont[io].LastError=0)and(sessiont[io].TcpSite<>nil)and(not sessiont[io].TcpSite.Active) do
                application.ProcessMessages;
            if sessiont[io].TcpSite=nil then exit;
            inc(sessiont[io].step);
            if not sessiont[io].TcpSite.Active then
            begin
               socket.SendText(VER+chr(sessiont[io].LastError));
            end
            else socket.SendText(VER+#0#0#1+ LongwordToS(inet_addr(pchar(socket.LocalAddress))) + WordToS(htons(socket.LocalPort)));
//            caption:=inttostr(socket.LocalPort);
         end;
       end;
      $00000205:
       begin //客户端把自己的Listen端口告诉代理端
         p:=3;
         siteHost:=jiaGetSock5Host(@ReceiveBuf,p);
//         if siteHost<>'' then
         begin
//            session[i].ConnectOrListen:=true; //客户是Connect
            sessiont[io].TcpClient:=socket;
            sessiont[io].ListenServer:=TServerSocket.Create(nil);
            sessiont[io].ListenServer.OnClientConnect:=ListenServerClientConnect;
            sessiont[io].ListenServer.OnClientDisconnect:=ListenServerClientDisconnect;
            sessiont[io].ListenServer.OnClientError:=ListenServerClientError;
            sessiont[io].ListenServer.OnClientRead:=ListenServerClientRead;

            sessiont[io].ListenServer.Port:=ntohs( pword(@ReceiveBuf[p])^ );
            try
               sessiont[io].ListenServer.Active:=true;
            except
            end;
            if not sessiont[io].ListenServer.Active then
            for p:=0 to 10000 do
            begin
               sessiont[io].ListenServer.Port:=LastPort;
               inc(LastPort);
               if LastPort=MAXWORD then LastPort:=StartPort;
               try
                  sessiont[io].ListenServer.Active:=true;
                  break;
               except
               end;
            end;
            sessiont[io].ListenServer.Socket.Data:=pointer(io);
            inc(sessiont[io].step);
            socket.SendText(VER+#0#0#1+ LongwordToS(inet_addr(pchar(socket.LocalAddress))) + WordToS(htons(sessiont[io].ListenServer.Port)));
         end;
       end;
      end;
   end
   else if (sessiont[io].step=3) then
   begin
      if (sessiont[io].TcpSite<>nil)then
      begin
         if (sessiont[io].TcpSite.Active) then
         begin
            while (not sessiont[io].close)and(sessiont[io].TcpSite.Socket.SendBuf(ReceiveBuf,ReceiveBufLength)=-1) do
               sleep(100);
         end
         else socket.Close;
      end
      else if (sessiont[io].ListenOneThread<>nil)then
      begin
         if sessiont[io].ListenOneThread.Connected then
         begin
            while (not sessiont[io].close)and(sessiont[io].ListenOneThread.SendBuf(ReceiveBuf,ReceiveBufLength)=-1) do
               sleep(100);
         end;
      end;
   end;
end;


function TSocks5Proxykk.jiaGetSock5Host(buf:pchar;var p:integer):string;
var
   s:string;
   ip:longword;
begin
   result:='';
   case buf[p] of
   #1:begin
         ip:=Plongword(@buf[p+1])^;
         if ip<>0 then
            result:=string(inet_ntoa(Tinaddr(ip)));
         inc(p,5);
      end;
   #3:begin
         setlength(s,ord(buf[p+1]));
         move(buf[p+2],s[1],ord(buf[p+1]));
         result:=s;  //GetIP(s);
         inc(p,ord(buf[p+1])+2);
      end;
   end;
end;


constructor TSocks5Proxykk.Create(taoshis: TLabel);
  procedure InitProxyServer;
  begin
    with ServerSocket2 do
    begin
      OnClientConnect := ServerSocket2ClientConnect;
      OnClientDisconnect := ServerSocket2ClientDisconnect;
      OnClientRead := ServerSocket2ClientRead;
      OnClientError :=ServerSocket2ClientError
    end;
  end;

  procedure InitLookupTimer;
  begin
    with TimerRefreshjia do
    begin
      Interval := 200;
      Enabled := False;
      OnTimer := TimerRefreshTimerjia;
    end;
  end;
begin
  LastPort:=StartPort;//最后一个使用的udp端口,可设为任意值
  ServerSocket2 := TServerSocket.Create(nil);
  InitProxyServer;
  TimerRefreshjia := TTimer.Create(nil);
  InitLookupTimer;
  NMUDP1:= TMYNMUDP.Create(nil);
  ttaoshi:=taoshis;
end;

destructor TSocks5Proxykk.Destroy;
begin
  TimerRefreshjia.Free;
  ServerSocket2.Free;
  NMUDP1.Free;
  inherited;
end;

procedure TSocks5Proxykk.StopServer;
begin
  TimerRefreshjia.Enabled := False;
  ServerSocket2.Active := False;
end;

procedure TSocks5Proxykk.StartServer;
begin
try
  ServerSocket2.Port := FPort;
  ServerSocket2.Active := True;
except
end;
end;

procedure TSocks5Proxykk.SetPort(const Value: Integer);
begin
  if not ServerSocket2.Active then
  begin
    FPort := Value;
  end;
end;

procedure TSocks5Proxykk.SetUser(const Value: String);
begin
    FUser := Value;
end;

procedure TSocks5Proxykk.SetPass(const Value: String);
begin
    FPass := Value;
end;

procedure TSocks5Proxykk.ServerSocket2ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
   i,j:integer;
begin
   j:=-1;
   //从客户端，代理服务器，网站端关系记录数组中找一个休眠记录
   for i:=0 to length(sessiont)-1 do
   begin
      if (not sessiont[i].Valid)then
      begin
         j:=i;
         sessiont[j].Valid:=true;
         sessiont[j].close:=false;
         break;//找到后退出
      end;
   end;
   if j=-1 then //如果没有找到休眠记录，新建一个记录
   begin
      j:=length(sessiont);
      setlength(sessiont,j+1); //重新设置记录数量
      sessiont[j].Valid:=true;
      sessiont[j].close:=false;
   end;
//   session[j].ClientS:=socket; //客户端口
   socket.Data:=pointer(j);    //会话指针
   sessiont[j].step:=0;//第0步
   sessiont[j].UdpSite:=nil;
   sessiont[j].jiabinUdpClient:=nil;
   sessiont[j].TcpSite:=nil;
   sessiont[j].TcpClient:=nil;
   sessiont[j].ListenServer:=nil;
end;

procedure TSocks5Proxykk.ServerSocket2ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
   i:integer;
begin
   i:=integer(Socket.data);
   sessiont[i].TcpClient:=nil;
   sessiont[i].close:=true;
   if sessiont[i].ListenServer<>nil then
      if sessiont[i].ListenServer.Active then
         sessiont[i].ListenServer.Active:=false;
   TimerRefreshjia.Enabled:=true;
end;

procedure TSocks5Proxykk.ServerSocket2ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   errorcode:=0;
   if Socket.Connected then Socket.close;
   ServerSocket2ClientDisconnect(Sender,Socket);
end;

procedure wait(ticks:dword);
var
   t:dword;
begin
   t:=gettickcount;
   while gettickcount-t<ticks do application.ProcessMessages;
end;



procedure TSocks5Proxykk.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
//
end;

procedure TSocks5Proxykk.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
   i:integer;
begin
   i:=(sender as TClientsocket).tag;
   sessiont[i].close:=true;
   if sessiont[i].LastError=0 then
      sessiont[i].LastError:=-1;
   TimerRefreshjia.Enabled:=true;
end;

procedure TSocks5Proxykk.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  sessiont[(Sender as TClientSocket).tag].LastError:=ErrorCode;
  errorcode:=0;
  if Socket.Connected then Socket.close;
  ClientSocket1Disconnect(Sender,Socket);
end;

procedure TSocks5Proxykk.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
  i:integer;
  Rectext:string;
begin
   i:=(sender as TClientsocket).tag;
   if sessiont[i].close then exit;
   Rectext:=socket.ReceiveText;
   if sessiont[i].TcpClient.Connected then
      while (not sessiont[i].close)and(sessiont[i].TcpClient.SendText(Rectext)=-1)do //发送数据
         sleep(100);
end;

procedure TSocks5Proxykk.TimerRefreshTimerjia(Sender: TObject);
var
   i:integer;
begin
   TimerRefreshjia.Enabled:=false;
   for i:=length(Sessiont)-1 downto 0 do
   begin
      if sessiont[i].close then
      begin
         if (sessiont[i].TcpClient<>nil) then
         begin
            if (sessiont[i].TcpClient.Connected) then
               sessiont[i].TcpClient.Close;
            //不用free
            sessiont[i].TcpClient:=nil;
         end;
         if (sessiont[i].TcpSite<>nil) then
         begin
            if (sessiont[i].TcpSite.Active) then
               sessiont[i].TcpSite.Close;
            sessiont[i].TcpSite.free;
            sessiont[i].TcpSite:=nil;
         end;
         if sessiont[i].UdpSite<>nil then
         begin
            sessiont[i].UdpSite.Free;//释放udp端口
            sessiont[i].UdpSite:=nil;
         end;
         if sessiont[i].jiabinUdpClient<>nil then
         begin
            sessiont[i].jiabinUdpClient.Free;//释放udp端口
            sessiont[i].jiabinUdpClient:=nil;
         end;
         if (sessiont[i].ListenServer<>nil) then
         begin
            if sessiont[i].ListenServer.Active then
                sessiont[i].ListenServer.Active:=false;
            sessiont[i].ListenServer:=nil;
         end;
         sessiont[i].Valid:=false;
      end;
   end;
end;

procedure TSocks5Proxykk.jiabinNMUDP1DataReceived(Sender: TComponent;
  NumberBytes: Integer; FromIP: String; Port: Integer);
type
  TCharArray1024=array[0..2048] of char;
  PCharArray1024=^TCharArray1024;
var
   hh, p,i:integer;
    siteHost:string;
    buffer:array[0..2048] of char;
    s:string;
    np: Pointer;

begin
    i:=(Sender as TMYNMUDP).Tag and (not IsServer); //连接序号
    NumberBytes:=min(sizeof(buffer),NumberBytes);
    if ((Sender as TMYNMUDP).Tag and IsServer) <>0 then
    begin //表示这是网站发过来的
       (Sender as TMYNMUDP).ReadBuffer(PCharArray1024(@buffer[10])^, NumberBytes);
       plongword(@buffer)^:=$01000000;
       pdword(@buffer[4])^ := inet_addr(pchar(FromIP));
       pword(@buffer[8])^:= htons(Port);
       if sessiont[i].jiabinUdpClient<>nil then
          sessiont[i].jiabinUdpClient.SendBuffer(buffer,NumberBytes+10);
    end
    else begin //表示客户发过来的
       if (NumberBytes>=4)then
       begin
          sessiont[i].jiabinudpClient.RemotePort:=Port;
          (Sender as TMYNMUDP).ReadBuffer(buffer, NumberBytes);
          if(sessiont[i].UdpSite<>nil) and (pdword(@buffer)^ and $00ffffff=$00000000)then //以IP v4格式的IP地址来发送
          begin
             p:=3;
             siteHost:=jiaGetSock5Host(@Buffer,p);
             if siteHost<>'' then
             begin
                sessiont[i].UdpSite.RemoteHost:= siteHost;

                sessiont[i].UdpSite.RemotePort:= ntohs( pword(@Buffer[p])^ );
            //  ttaoshi.Caption:=ntohs( pword(@Buffer[p])^);
                inc(p,2);
                sessiont[i].UdpSite.SendBuffer(PCharArray1024(@buffer[p])^,NumberBytes- p);
             end
          end;
       end;
    end;
end;

procedure TSocks5Proxykk.ListenServerClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
var
   i:integer;
begin
   if (Sender as TServerWinSocket).ActiveConnections>1 then
   begin
      Socket.Data:=pointer(-1);
      Socket.Close;
      exit;
   end;
   i:=integer((Sender as TServerWinSocket).Data);
   Socket.Data:=pointer(i);
   sessiont[i].ListenOneThread:=Socket;
   sessiont[i].TcpClient.SendText(VER+#0#0#1+ LongwordToS(Longword(socket.RemoteAddr.sin_addr)) + WordToS(ntohs(Socket.RemotePort)));
end;

procedure TSocks5Proxykk.ListenServerClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
var
   i:integer;
begin
   i:=integer(Socket.data);
   if i=-1 then exit;
   sessiont[i].close:=true;
//   if session[i].ListenServer.Active then
//      session[i].ListenServer.Active:=false;
   TimerRefreshjia.Enabled:=true;
end;

procedure TSocks5Proxykk.ListenServerClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
begin
   ErrorCode:=0;
   ListenServerClientDisconnect(Sender,Socket);
end;

procedure TSocks5Proxykk.ListenServerClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
var
   i:integer;
begin
   i:=integer(Socket.data);
   if i=-1 then exit;
   if (not sessiont[i].close)and(sessiont[i].TcpClient<>nil)and(sessiont[i].TcpClient.Connected) then
   begin
     while (not sessiont[i].close)and(sessiont[i].TcpClient.SendText(Socket.ReceiveText)=-1)do
        sleep(100);
   end;
end;

end.
