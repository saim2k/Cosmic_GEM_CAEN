int socket, ThNo; 
unsigned port;
//dyn_string fdata;
string fdata;
initRadMon(string ip,unsigned port)
{
  
 dyn_errClass err; 
    
   socket=tcpOpen(ip, port); 
   err=getLastError(); 
   DebugN("Port No="+socket); 
   DebugN(err);
   
}
readRadMon(string RadDp1)
{
  ThNo=startThread("readRadMonTh",RadDp1);
  //DebugN("Thread Strarted is "+ThNo);
         
}
readRadMonTh(string RadDp)
{
  
   int read,write,pos,dc,strl;

   time maxTime;

   string data;
   //dyn_string fdata;
   time maxTime = 2;
  DebugN("Thread Strarted is Running for"+RadDp); 
  while(1)
  {
   write=tcpWrite(socket, "g");
   read=tcpRead(socket, data, maxTime);
   strl=strlen(data);
   if(strl>92)
   {
     pos=strl-92;
     fdata=substr(data,pos);
     updateDP(RadDp);
   }
   else
   {
     //fdata=makeDynString("No Data");
     DebugN("FData length="+strl);
     fdata="";
   }
   //fdata=strsplit(data,"Radmon No:0");
   //dc=dynCount(fdata,"Radmon No:0");
   //radtxt.text=fdata;   
   //DebugN("write="+write); 
   //DebugN("Data="+data); 
   delay(30);
   ThNo=getThreadId();
   DebugN("Thread loop "+ThNo);
   DebugN(getCurrentTime());
  }   
  //ThNo=getThreadId();
}
updateDP(string dp)
{
  string tmp;
  int strl;
  float j;
  strl=strlen(fdata);
  DebugN("FData length="+strl);
  if(strl>91)
  {
  tmp=substr(fdata,9,5);
  j=(float)tmp;
  dpSet(dp+".actual.Rth",j);
  tmp=substr(fdata,28,6);
  j=(float)tmp;
  dpSet(dp+".actual.REM250",j);
  tmp=substr(fdata,46,6);
  j=(float)tmp;
  dpSet(dp+".actual.REM130",j);
  tmp=substr(fdata,64,6);
  j=(float)tmp;
  dpSet(dp+".actual.BPW34s",j);
  tmp=substr(fdata,82,6);
  j=(float)tmp;
  dpSet(dp+".actual.SI1",j);
  }
}
RadMonClose()
{
  tcpClose(socket);
  DebugN("Socket closed");
}
