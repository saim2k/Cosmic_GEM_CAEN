//**************** HV ON
// default gemNo=0 means all GEMs
bool fwGEM_ChOn(string chtype, bool ON,int gemNo=0)
{
 dyn_string hvch,dppmt;
  int len,gem;
  bool chmask;
  dpGetAllAliases(hvch,dppmt,chtype);
  len=dynlen(hvch);
  gem=0;
  if(gemNo!=0 && len >=1 )
  {
    len=1;
    gem=(gemNo-1);
  }
  
  for(int ch=1; ch<=len ; ch++)
   {  
    
     dpGet(hvch[ch+gem]+"mask",chmask);
    if(!chmask)
    {   
     if(dpSetWait(hvch[ch+gem]+"settings.onOff",ON)==-1)
     {
      DebugN("Error Switching ON/OFF for "+ hvch[ch+gem]);
     }
    }
  }
}
//***************** Power Converter ON OFF
bool fwGEM_PCOn(string chtype, bool ON)
{
 bool pcst;
 dyn_string hvch,dppmt;
 dpGetAllAliases(hvch,dppmt,chtype);
 dpGet(hvch[1]+"actual.isOn",pcst);
 if(!pcst)
  {
   if(dpSetWait(hvch[1]+"settings.onOff",ON)==-1)
    DebugN("Error Switching ON/OFF for "+ hvch[1]);
   delay(2);
  }
 else if(!ON)
   if(dpSetWait(hvch[1]+"settings.onOff",ON)==-1)
    DebugN("Error Switching OFF for "+ hvch[1]);
}
//**************** LV ON
// default gemNo=0 means all GEMs
bool fwGEM_LVChOn(string chtype, bool ON,int gemNo=0)
{
  dyn_string lvch,dppmt;
  int len,gem;
  bool chmask;
  dpGetAllAliases(lvch,dppmt,chtype);
  len=dynlen(lvch);
  gem=0;
  if(gemNo!=0 && len >=3 )
  {
    len=3;
    gem=(gemNo-1)*3;
  }
  
  for(int ch=1; ch<=len ; ch++)
   {  
    
     dpGet(lvch[ch+gem]+"mask",chmask);
    if(!chmask)
    {   
     if(dpSetWait(lvch[ch+gem]+"settings.onOff",ON)==-1)
     {
      DebugN("Error Switching ON/OFF for "+ lvch[ch+gem]);
     }
    }
  }
}
