#NoEnv
#SingleInstance force
#Persistent
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
Sendmode, Input
CoordMode, Pixel
Menu Tray, Icon, cfg/icon.ico

;--- Start GUI ---;
IniRead, HK, cfg/cfg.ini, Hotkey, Key
oldKey := HK
Hotkey, %oldKey%, Checkbox, On
Gui Add, CheckBox, x123 y14 w90 h23 vToggleCheckBox gcheckBox , Enable
Gui Add, Hotkey, x14 y15 w98 h20 gtoggleKey vHK, %HK%
Gui Add, Text, x14 y46 w199 h21 +0x200, Dota 2 Window must be focused!
Gui Show, w224 h77, D2AAC
Menu, Tray, Add, Restore, Restore
Menu, Tray, default, Restore
Menu, Tray, Click, 2
Return

checkBox:
Toggle()
Return


toggleKey:
 IniWrite, %HK%, cfg/cfg.ini, Hotkey, Key
 If HK in +,^,!,+^,+!,^!,+^!            ;If the hotkey contains only modifiers, return to wait for a key.
  return
 If (savedHK) {                         ;If a hotkey was already saved...
  Hotkey, %savedHK%, Checkbox, Off        ;     turn the old hotkey off
  savedHK .= " OFF"                     ;     add the word 'OFF' to display in a message.
 }
 If (HK = "") {                         ;If the new hotkey is blank...
  TrayTip, Checkbox, %savedHK%, 5         ;     show a message: the old hotkey is OFF
  savedHK =                             ;     save the hotkey (which is now blank) for future reference.
  return                                ;This allows an old hotkey to be disabled without enabling a new one.
 }
 Gui, Submit, NoHide
 If CB                                  ;If the 'Win' box is checked, then add its modifier (#).
  HK := "#" HK
 If StrLen(HK) = 1                      ;If the new hotkey is only 1 character, then add the (~) modifier.
  HK := "~" HK                          ;     This prevents any key from being blocked.
 Hotkey, %oldKey%, Checkbox, Off
 Hotkey, %HK%, Checkbox, On               ;Turn on the new hotkey.
 savedHK := HK                          ;Save the hotkey for future reference.
Return

GuiSize:
  if (A_EventInfo = 1)
    WinHide
Return

Restore:
  gui +lastfound
  WinShow
  WinRestore
  GuiControl, Focus, tab
Return

GuiClose:
    ExitApp

;--- END GUI ---;

Toggle()
{
static i = true
if (i = true){
    if WinActive("ahk_exe dota2.exe") {
    OSD("AutoAccept On",A_ScreenWidth*0.7,-A_ScreenHeight*0.0065)
    }
    SetTimer, CheckWindow, On
    SetTimer, AutoAccept, On
    GuiControl,, ToggleCheckbox, 1
    i := false
}
else {
    SetTimer, CheckWindow, Off
    SetTimer, AutoAccept, Off
    GuiControl,, ToggleCheckbox, 0
    Gui, OSD:Destroy
    i := true
}
}
Return

AutoAccept:
IfWinActive ahk_class SDL_app
{
ImageSearch, px, py, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 cfg/accept.png
    if Errorlevel = 2
    {
        msgbox, could not counduct the ImageSearch
    }
    else if ErrorLevel = 1  
    {
    }
    else 
    {
        Blockinput, On
        Sleep, 50
        ControlSend, ,{Enter}, ahk_class SDL_app
        Blockinput, Off
        Msgbox, Game Found!
        Sleep, 300
        Toggle()
    }
    Return
}
Return

CheckWindow:
    Process, Exist, dota2.exe
        if (!Errorlevel = 0) {
        WinwaitActive, ahk_exe dota2.exe
        OSD("AutoAccept On",A_ScreenWidth*0.7,-A_ScreenHeight*0.0065)
        WinWaitNotActive, ahk_exe dota2.exe
        Gui, OSD:Destroy
    } else {
        Msgbox, Dota 2 not running! Open it and enable D2AAC again.
        Toggle()
    }
Return

OSD(text,posx,posy)
{
Gui, OSD:Default
Gui, OSD:Destroy
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, EEAA99
Gui, Font, s16  ; Set a font size .
Gui, Add, Text, cLime, %text%  ; XX & YY serve to auto-size the window.
; Make all pixels of this color transparent and make the text itself translucent (150):
WinSet, TransColor, EEAA99 150
Gui, Show, x%posx% y%posy% NoActivate 
}
Return