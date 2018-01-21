
//const string fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX = "fwFsmUserCMS_Viewer_";
const string fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX = "CMS_GEM_Main_";
const string fwFsmUserCMS_FSM_VIEWER_PANEL_NAME = "FSMModule";

const int fwFsmUserCMS_MAX_TABS = 10;
global  bool cr;
global string moduleName; 
global dyn_string fwFsmUser_tabList;


FSM_operator_selected(string node, string parent)
{
  return;
}
    
FSM_operator_entered(string node, string parent)
{
  int answer;
  
  popupMenu(makeDynString("PUSH_BUTTON", "Show in current tab", 1, 1,
                          "PUSH_BUTTON", "Show in new tab", 2, 1,
                          "PUSH_BUTTON", "Get node info", 3, 1), answer);
  if(answer == 2)
  {
      fwFsmUserCMS_showInNewTab(node, parent);
  }
  else if(answer == 1)
  {
    if(!fwFsmUserCMS_checkExistingTab(node, false))
      fwFsmTree_openPanel(node, parent);
  }
  else if(answer == 3)
    fwFsmTree_showInfo(node, parent);  
}


fwFsmUserCMS_showInNewTab(string node, string parent){
  shape tabs;  
//DebugN(moduleName, "cmsViewer", getShapes(moduleName, "cmsViewer", "shapeType", "TAB"));
//DebugN("fwFsmUserCMS_showInNewTab", node, parent);  

  if(!shapeExists("CentralDCSFsmTab")){     
    tabs = getShape(moduleName + ".cmsViewer:CentralDCSFsmTab");     
  }
  else{
    tabs = getShape("CentralDCSFsmTab");
  }
  
  int count = tabs.registerCount();    
  if(count >= fwFsmUserCMS_MAX_TABS)
  {
    dyn_string exceptionInfo;
    fwException_raise(exceptionInfo, "WARNING", "The maximum number of tabs is " + fwFsmUserCMS_MAX_TABS + ". ", "");
    fwExceptionHandling_display(exceptionInfo);
    return;      
  }
    
  if((count == 1) && (tabs.registerHeader(0) == ""))
  {
    fwFsmTree_openPanel(node, parent);
  }
  else if(!fwFsmUserCMS_checkExistingTab(node, true))
  {
    tabs.insertRegister(count);
    fwFsmUserCMS_prepareTab(count);
    fwFsmTree_openPanel(node, parent);
  }
}

fwFSMUserCMS_init(bool isCr, string myName){
  cr=isCr;
  moduleName = myName;
  fwFsmUser_tabList = makeDynString();
}


fwFsmUser_nodeView(string domain, string obj, int x, int y)
{
  shape tabs;  
  if(!shapeExists("CentralDCSFsmTab")){        
   tabs = getShape(moduleName + ".cmsViewer:CentralDCSFsmTab");     
  }
  else{
    tabs = getShape("CentralDCSFsmTab");
  }
  
  bool isConnected;
  int currentTab = tabs.activeRegister();
  string tabId = tabs.registerName(currentTab);  
  string dp,sysName; dyn_string exc;
  fwCU_getDp(obj, dp);
  fwGeneral_getSystemName(dp, sysName, exc);
  if(sysName == "") { sysName = getSystemName(); }
  unDistributedControl_isConnected(isConnected, sysName);
//DebugN(isConnected, sysName, currentTab);
  if(!isConnected)
  {
    tabs.deleteRegister(currentTab);
    return;
  }
  string label= fwFsmTree_getNodeLabel(sysName + obj);
  if (strlen(label) == 0) label = obj;  

  tabs.registerHeader(currentTab, label);    


  while(!isModuleOpen(fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId))
    delay(0,100);
  if(isPanelOpen(fwFsmUserCMS_FSM_VIEWER_PANEL_NAME+tabId, fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId))
    PanelOffModule(fwFsmUserCMS_FSM_VIEWER_PANEL_NAME+tabId, fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId);

  
  while(isPanelOpen(fwFsmUserCMS_FSM_VIEWER_PANEL_NAME+tabId, fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId))
    delay(0,100);

    if(!cr)
    RootPanelOnModule("CMS_GEM_CAEN/fwUi_CMS_FSMModule.pnl", fwFsmUserCMS_FSM_VIEWER_PANEL_NAME+tabId,
                                                          fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId,
                                                          makeDynString("$obj:" + obj, 
                                                                        "$node:" + domain,
                                                                        "$bCr:"+cr));
    else
      RootPanelOnModule("CMS_GEM_CAEN/fwUi_CMS_FSMModuleCR.pnl", fwFsmUserCMS_FSM_VIEWER_PANEL_NAME+tabId,
                                                          fwFsmUserCMS_FSM_VIEWER_MODULE_PREFIX + tabId,
                                                          makeDynString("$obj:" + obj, 
                                                                        "$node:" + domain,
                                                                        "$bCr:"+cr));
    fwFsmUser_tabList[currentTab + 1] = obj;
    
}

bool fwFsmUserCMS_checkExistingTab(string node, bool newTab=false)
{
   shape tabs;  
  if(!shapeExists("CentralDCSFsmTab")){      
   tabs = getShape(moduleName + ".cmsViewer:CentralDCSFsmTab");     
  }
  else{
    tabs = getShape("CentralDCSFsmTab");
  }
  int count = tabs.registerCount();
  int currentTab = tabs.activeRegister();
  
  //DebugN("Check existing tab " , fwFsmUser_tabList, node);
  for(int i=0; i<count; i++)
  {
   /* if(node == tabs.registerHeader(i)) */
    if (node == fwFsmUser_tabList[i +1])
    {
      bool confirmed;
      dyn_float df;
      dyn_string ds;

      //if opening in current tab, and current tab shows node - DO NOTHING
      if(i == currentTab)
      {
        //what if opening in a new tab and current tab shows node?????
        if(newTab)
        {
          dyn_string exceptionInfo;
          fwException_raise(exceptionInfo, "WARNING", "The node is already open in the existing tab. " +
                                                      "A new tab has not been created.", "");
          fwExceptionHandling_display(exceptionInfo);
        }

        return TRUE;         
      }
      

      //if node already open in another tab (not current tab)   
      ChildPanelOnCentralModalReturn("fwGeneral/fwOkCancel.pnl", "Node already open",
           				                    makeDynString("$text:The node '" + tabs.registerHeader(i) +
                                                    "' is open in another tab.\n" +
                                                    "Do you want to show this tab now?"),
			                                df, ds);

      confirmed = (ds[1]=="ok"); 
      if(!confirmed)
        return TRUE;
      else
      {
        tabs.activeRegister(i);
        return TRUE;
      }
    }
  }
  
  return FALSE;
}

fwFsmUserCMS_prepareTab(int count){  
  shape tabs;  
  if(!shapeExists("CentralDCSFsmTab")){     
   tabs = getShape(moduleName + ".cmsViewer:CentralDCSFsmTab");     
  }
  else{
    tabs = getShape("CentralDCSFsmTab");
  }

  time t = getCurrentTime(); 
  int seconds = t;
  int milli = milliSecond(t);
  
  string id = (string)seconds + (string)milli;
  tabs.registerName(count, id);
  tabs.activeRegister(count);
  DebugN("prepare tab called from control room screen? " + cr);
  DebugN("Tab id in prepare tab is : " + id);
  
  tabs.registerPanel(count, "CMS_GEM_CAEN/fwUi_CMS_ModuleInModule.pnl", makeDynString("$iTabId:"+id,"$bCR:"+ cr));

    
 
}

fwFsmUserCMS_doubleClickAction(string node, string parent){
  DebugN("Double click action " + node + parent);
  fwFsmUserCMS_showInNewTab(node, parent);
}

fwFsmUser_nodeDoubleClicked(string domain, string obj, string parent = ""){

  fwFsmUserCMS_showInNewTab(obj, domain);
 
}


fwFsmUser_nodeRightClicked(string domain, string obj, string parent = ""){
//DebugN(domain, obj, parent);
	int x,y, answer;
	dyn_string lines;

  getValue("","position",x,y);
 	 dynAppend(lines, "PUSH_BUTTON,Description, 1, 1");
  		if((domain != obj) && (parent == ""))
    			dynAppend(lines, "PUSH_BUTTON,Show Parent, 2, 1");

		dynAppend(lines, "SEPARATOR");
		dynAppend(lines, "PUSH_BUTTON,Restart FSM, 3, 0");
		popupMenu(lines, answer);
  		if(answer == 1)
  		{
    			ChildPanelOn("fwFSM/ui/fwFsmObjDescript.pnl","Description",
      			makeDynString($domain, $obj), x, y+25);
  		}
  		else if(answer == 2)
  		{
    			fwCU_view($domain);
  		}
  		else if(answer == 3)
  		{
 			fwFsmUi_restartFSM(domain, obj);
		}	
}

fwUi_showFsmObject(string domain, string obj, string parent = "", int posx = -1, int posy = -1,
	int posx_offset = 100, int posy_offset = 70)
{
//DebugN("fwUi_showFsmObject", domain, obj, parent);
	fwFsmUserCMS_showInNewTab(obj, domain);
}

void fwFSMUserCMS_closeTab(int tabIndex) {    
  this.deleteRegister(tabIndex);
  dynRemove(fwFsmUser_tabList, tabIndex +1);  
}
