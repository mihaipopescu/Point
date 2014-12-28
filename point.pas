{M 1095,0,655360}                                                 {156200}
{$I Coptions.inc}
Program Point;    {Point software}
Uses crt, graph, gui,  gdi, dpms, keyboard, Task, XMSArray;

Const{cmxxxx               CoMmands}
  cmOpen        = 100;
  cmNew         = 101;
  cmSave        = 102;
  cmExit        = 103;
  cmCopy        = 104;
  cmPaste       = 105;
  cmFiles       = 106;
  cmEditor      = 107;
  cmColors      = 108;
  cmHelpAbout   = 109;
  cmHelpContext = 110;
  
Const{hcxxxx             Help Context}
  hcFile    = 10;
  hcEdit    = 11;
  hcOptions = 12;
  hcHelp    = 13;
Var
  menu1 : PMenu;                                 {Menu1 used by window 2}
  Ma    : LongInt;
  
Var id1, VInit, vRun : Byte;
  
  {***********************************}
  {***Point Procedures declarations***}
  {***********************************}
  

Procedure proc1; Far;
Begin
  If (Not WindowExist (1) ) Then
  Begin
    LoadWindow ('windows.prc', 1, 1, Nil);
 {   SetWindowsFlagsOff (1, 0);}
  End;
End;

Procedure proc2; Far;
Begin
  If (Not WindowExist (2) ) Then
  Begin
    If (Not MenuExist (2) ) Then
      Menu1 := NewMenu (
      NewSubMenu ('&Load', hcFile, NewMenu (
      NewItem ('&MyComputer', cmOpen, hcNoContext,
      NewItem ('&EmptyBin', cmNew, hcNoContext,
      NewItem ('&FullBin', cmSave, hcNoContext,
      NewLine (
      NewItem ('&Exit', cmExit, hcNoContext,
      Nil) ) ) ) ) ),
      NewSubMenu ('&Edit', hcEdit, NewMenu (
      NewItem ('&Copy', cmCopy, hcNoContext,
      NewItem ('&Paste', cmPaste, hcNoContext,
      Nil) ) ),
      NewSubMenu ('&Options', hcOptions, NewMenu (
      NewItem ('&Files', cmFiles, hcNoContext,
      NewSubMenu ('&Environment', hcNoContext, NewMenu (
      NewItem ('&Editor', cmEditor, hcNoContext,
      NewItem ('&Colors', cmColors, hcNoContext,
      Nil) ) ), Nil) ) ),
      NewSubMenu ('&Help', hcHelp, NewMenu (
      NewItem ('&About', cmHelpAbout, hcNoContext,
      NewItem ('&Context', cmHelpContext, hcNoContext,
      Nil) ) ), Nil) ) ) ) );

     LoadWindow ('windows.prc', 2, 2, Menu1);
  End;
End;

Procedure proc3; Far;
var img:PXMS2DArray;
Begin
DebugBar('GetXMSImage / PutXMSImage Demo');
img:=GetXMSImage(0,0,GetMaxx,GetMaxy);
ClearDevice;
PutXMSImage(img,0,0,GetMaxx,getmaxy);
End;

Procedure shutdown; Far;
Var r, g, b: Byte;
Begin
 { GetPal (0, r, g, b);
  SetPal (3, r, g, b);   }
  If (Not WindowExist (3) ) Then
  Begin
    LoadWindow ('windows.prc', 3, 3, Nil);
    SetWindowsFlagsOff (3, FLMaximize + FLMinimize + FLClose);
  End;
End;


Procedure proc4; Far;
Begin
  If (Not WindowExist (4) ) Then
     LoadWindow ('windows.prc', 4, 4, Nil);
End;

Procedure proc_PlayHsc; Far;
Begin
End;

Procedure DpmsWait;
Var mx, my: Word;
Begin
  mx := mouse. WhereX; my := mouse. WhereY;
  Repeat Until (AltPress) Or (CtrlPress) Or (KeyPressed) Or (mx <> mouse. WhereX) Or (my <> mouse. WhereY);
End;

Procedure SetSuspendEvent (Mode: Byte);
Begin
  If Card_config Then
  Begin
    SetDisplayMode (Mode);
    DpmsWait;
    SetDisplayMode (Mode_On);
  End;
End;

Procedure HandleMenuEvent (nr: Byte);
Begin
  If SelectedMenuCommand <> $00 Then
    Case SelectedMenuCommand Of
      cmOpen : load_iconWin32 (100, 100, 'Computer.ico', DeskTop_color);
      cmNew  : load_iconWin32 (100, 140, 'EmptyBin.ico', DeskTop_color);
      cmSave : load_iconWin32 (100, 180, 'FullBin.ico' , DeskTop_color);
      cmHelpAbout : Debugbar ('Copyright by System Quick Programming Group.');
      cmExit : InDirect_close := nr;
      0 : DebugBar ('This is a submenu ...');
    End;
  SelectedMenuCommand := $00;
End;

Procedure HandleStartMenu;
Begin
  If SStartMenuCmd <> $00 Then
  Begin
    mouse. hidemousecursor;
    mouse. setHourGlassCursor;
    mouse. showmousecursor;
    Case SStartMenuCmd Of

      cmPShutDown : ShutDown;
      cmPSuspend  : SetSuspendEvent (Mode_Suspend);
      cmPDocuments: proc1;
      cmPPointExp : proc2;
      cmPSettings : Proc3;
      cmPHelp     : proc4;
      cmPSearch   : proc_PlayHsc;

    End;
    mouse. hidemousecursor;
    mouse. setArrowCursor;
    mouse. showmousecursor;
    SStartMenuCmd := $00;
  End;
End;

Procedure HandleButtons;
Begin
  If SelectedButton <> $00 Then
  Begin
    Case WinButtons Of
      1:
         Begin
           Case SelectedButton Of
             1 :
                 Begin

                   If SelectedCeckBoxElement (Winbuttons,1,1) Then Begin debugBar ('Element 1 was selected'); readkey; End;
                   If SelectedCeckBoxElement (Winbuttons,1,2) Then Begin debugBar ('Element 2 was selected'); readkey; End;
                   If SelectedCeckBoxElement (Winbuttons,1,3) Then Begin debugBar ('Element 3 was selected'); readkey; End;

                   Indirect_close := WinButtons;
                 End;
             2 : Indirect_close := WinButtons;

           End;
         End;
      3:
         Begin
           Case SelectedButton Of
             1 : if SelectedRadioBox<>0 then
                 Begin indirect_close := WinButtons;
                   If SelectedRadioBox <> $00 Then
                     Case SelectedRadioBox Of
                       1 : quit := True;
                       2 : Begin SetSuspendEvent (Mode_Suspend); Reset_Colors; End;
                     End;
                   SelectedRadioBox := $00;
                 End;
             2 :
                 Begin indirect_close := WinButtons;
                   SelectedRadioBox := $00;
                   Reset_Colors;
                 End;
           End;
         End;
      4:
         Begin
           Case SelectedButton Of
             1 : Begin indirect_close := WinButtons;
                   { with Get_wnd(WinButtons)^.WindowPos do
                   DebugBar(Int2str(x1)+' '+Int2str(y1)+' '+Int2str(x2)+' '+Int2str(y2));readkey;
                   }
                 end;
             2 :
                 Begin indirect_close := WinButtons;
                   { with Get_wnd(WinButtons)^.WindowPos do
                   DebugBar(Int2str(x1)+' '+Int2str(y1)+' '+Int2str(x2)+' '+Int2str(y2));readkey;
                   }
                 End;

           End;
         End;
    End;
    SelectedButton := $00;
  End;
End;

Procedure proc_exit; Far;
Begin
  Quit := True;
End;

Procedure ddd (Var TaskPtr); Forward;
Procedure Point_Run (Var TaskPtr); Forward;

{**********************}
{**Point - MAIN PARTS**}
{**********************}

Procedure Point_Init;
Begin
  crt. ClrScr;
  init_graph;

  {intro_screen;}

  (* Init Vars *)
  DeskTop_color := 3;
  On_Sound := True;
  (* End Init Vars   *)
  gui. DrawMainScreen;
  mouse.init_mouse;
  id1 := TaskInit (DDD, $400, VInit);          {1 Kbyte}
  VInit := id1;
  id1 := TaskInit (Point_Run, $4000, VRun);    {16 KBytes reserved for GDI}
  VRun := id1;
End; (*Point_Init*)

Procedure wr_avail;
Begin
If MemAvail <> MA Then
   Begin
    DebugBar ('Memory avaible:' + Int2Str (Trunc (MemAvail) ) + ' Bytes : ' + Int2Str (Trunc (MemAvail / $A0000 * 100) ) +
    '% Free' +    ' , ' + Int2Str ($A0000 - MemAvail) + ' bytes used.');
    MA := MemAvail;
   End;
End;

Procedure Point_Run (Var TaskPtr);
Begin

  Repeat
    {the clock procedure}
    HandleClock;

    {... responsable for Start menu}
    StartPoint;

    {windows}
    HandleWindows;

    {buttons commands}
    HandleButtons;

    {to handle the menu events}
    HandleMenuEvent (2);

    {Start Menu}
    HandleStartMenu;

    wr_avail;
    TaskSwitch;
  Until Quit;

  mouse. hidemousecursor;
  mouse. setHourGlassCursor;
  mouse. showmousecursor;
   Fade_down (0);
  mouse. hidemousecursor;
  mouse. setArrowCursor;
  mouse. showmousecursor;
  TaskStop (VInit);
  CleanTempFiles;
End; (*Point_Run*)

Procedure Point_Done;
Begin
  mouse.destroy_mouse;
  destroy_graph;
  Halt (0);   {exit code 0}
End; (*Point_Done*)

Procedure DDD (Var TaskPtr);
Var i: Integer;
Begin
  i := 0; ClearKbd;
  If (quit = False) Then
    Repeat
      SetColor (i);
      SetTextStyle (DefaultFont, HorizDir, 0);
      OutTextXY (500, 10, 'System Q Point');
      i := i + 1;
      If i = 15 Then i := 0;
      TaskSwitch;
    Until (KeyPressed);
End;

Begin
  point_init;
  executetasks;
  point_done;
End.