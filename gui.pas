Unit                 { Graphic User Interface }
              { }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }
              { }{ }{ }{ }{ }   GUI;  { }{ }{ }{ }{ }{ }{ }
              { }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }{ }

{---------==========---------} Interface {---------==========---------}

uses mouse,graph,crt,dos,Task,GDI,HTRL;

{$I gdiconst.inc}
{$I mnuconst.inc}

{- variabile pentru personalizare -}

var DeskTop_color:byte;         {Culoarea Desktop-ului}
    On_Sound:boolean;           {sunet da/nu}

{ghost vars}
    SelectedMenuCommand:byte;   {comanda selectata din meniul unei ferestre}
    SStartMenuCmd:byte;         {comanda selectata din meniul principal [Start Menu]}
    SelectedButton:byte;        {Buttonul selectat}
    SelectedRadioBox:byte;      {radiobox-ul selectat din lista}
    SelectedCeckBox:byte;       {radiobox-ul selectat din lista}
    WinButtons:byte;            {butoanele carei ferestre sunt}
    indirect_close:byte;        {inchidere indirecta a unei ferestre}

    quit:boolean;                               {var for quitting ...}
    refresh:boolean;
    MaxWindowZ,ActiveWnd:byte;
    CBL : array [ 1 .. 32 ] of byte; {32*8 bool table for CeckBox}

type Tprocedure=procedure;

{- Tipul Menu - }
type
 PString=^String;               {pointer la string}
 PMenu = ^TMenu;                {pointer la TMenu}
 PMenuItem = ^TMenuItem;        {pointer la TMenuItem}
 TMenuStr = string[31];         {max length(MenuName) = 2^5-1}

 TMenuItem = record             {inregistrarea pt. TMenuItem (o unitate din meniu)}
   Next:PMenuItem;              {urmatoarea unitate}
   Name:PString;                {numele unitatii}
   Command:word;                {cmxxxx constants}
   Disabled:Boolean;            {default false}
   HelpCtx:word;                {hcxxxx - Help Context ordinal}
   SubMenu:PMenu;               {urmatorul submeniu}
 end;

TMenu = record                  {inregistrarea pentru TMenu}
 Items:PMenuItem;               {retine lista de unitati de meniu}
end;

{- Tipul fereastra -}

     FLTypes = (CloseFlag,MinimizeFlag,MaximizeFlag);

     wnd_Tstate=(normal,minimized,maximized,closed);     {starea ferestrei}

     wnd_type=(dialog,application);      {tipul ferestrei}

type PWindow=^TWindow;
     TWindow=record               {window resources}
         Name  :PString;          {retine numele ferestrei, utilizat pentru redraw_bar, dupa close}
     WindowPos :TWindowPosition;  {retine coordonatele ferestrei}
         State :wnd_Tstate;       {starea curenta}
         Menu  :PMenu;            {meniul (daca este tip=application <> nil, daca nu = nil}
         Max   :boolean;          {este TRUE cand state a fost maximize inainte de minimize}
         Xbar,                    {nr de ordine pe bara de taskuri}
         Id,                      {nr de identificare al ferestrei}
         Z     :byte;             {distanta 3D pe OZ de la desktop (Zd=0)}
        WType  :Wnd_type;         {tipul de fereastra}
         Next  :PWindow;          {pointer spre urmatoarea fereastra}
         Flags :byte;             {variabila care retine toate flagurile}
      ResourceF:String[127];      {fisierul cu resursele}
      end;

{- Variabilele unitatii -}

var DeskTop_pos:TWindowPosition;
    PWin:PWindow;
    StartMenu:PMenu;


{constructors & destructors}

{proceduri pentru ferestre}
procedure DrawWindow(win:PWindow);
          { procedura DrawWindow deseneaza o fereastra tridimensionala care are
            coordonatele x1,y1,x2,y2, avand culoarea color si textul de pe
            bara de sus s}

procedure NewWindow(Nr:byte);
          { procedura window are implementat comanda de inchidere si de drag-and-drop
            ca variabile de intrare sunt coordonatele x1,y1,x2,y2 care se introduc cu ajutorul
            variabilei de tip TWindowPosition=record, culoarea titlului si titlul;
            Variabila Window_on este variabila care ne spune daca fereasta este deschisa sau
            inchisa.
            procedura are implementata si functiile de close_wnd, move_wnd, resize_wnd
                 si maximize_wnd, minimize}

procedure HandleWindows;
          {procedura de management a ferestrelor}
procedure HandleWindowsControls(Wnd:PWindow);          {used by GUI}
          {procedura de management al controalelor ferestrelor}

function WindowExist(nr:byte):boolean;
           { verifica daca esista fereastra cu id-ul nr; vede daca poinerul catre fereastra
             cu id=nr este diferita de nil}

procedure SetWindowsFlagsOn(winId:byte;OFlag:byte);
procedure SetWindowsFlagsOff(winId:byte;OFlag:byte);
          {seteaza flagurile (on/off) (close,minimize,maximize)}

function GetWindowFlag(win:PWindow;Flt:FLTypes):boolean;
         {returneaza continutul flagurilor}

procedure OpenWindow(Nr:byte;_pos:TWindowPosition;title:string;tip:wnd_type;NMenu:Pmenu);
{incarca o fereastra in memorie direct (din program) }

procedure LoadWindow(ResF:string;nr,Wid:byte;NMenu:Pmenu);
{incarca o fereastra in memorie indirect dintr-un fisier cu resurse
(incarca resursa cu numarul nr si o introduce in memorie ca fereastra cu nr - Wid)}

{procedura pentru ceas}
procedure HandleClock;

{-- Buttons --}
procedure DrawButton(x,y,xx,yy :word;caption :string;_color:byte;click:boolean); {used by GUI}
          {Deseneaza un button}
procedure NewButton(Nr:byte;x1,y1,x2,y2:word; Caption:String);{used by GUI}
          {procedura pentru butoane}
{other}

function GetWindow(nr:byte):PWindow;{used by GUI}
         {returneaza fereastra cu numarul de ordine 'nr'}

procedure DrawMainBar;{used by GUI}
          {deseneaza bara principala}
procedure DrawMainScreen;{used by GUI}
          {deseneaza ecranul pincipal}
function SelectedCeckBoxElement(wnd_id,cb_id,nr:byte):boolean;
          {functie ce returneaza daca un element dintr-o lista de ceckbox a fost selectata}
procedure CleanTempFiles;
          {procedura ce sterge fisierele rendurante create de program}
{Menu implementation part}{used by GUI}

      function NewStr(const S: String): PString;
               {returneaza un pointer spre un string}
      procedure DisposeStr(P: PString);
               {Distruge pointrul creeat de NewStr}
      function MenuExist(nr:byte):boolean;
               {vede daca exista meniul ferestrei cu numarul ordine (nr)}
      function NewMenu(Items: PMenuItem): PMenu;
               {Creeaza un nou meniu returnand un pointer catre inregistrarea TMenu}
      function NewItem(Name: TMenuStr; Command: Word;AHelpCtx: Word; Next: PMenuItem): PMenuItem;
               {Creeaza o noua unitate de meniu, returnanad un pointer catre structura TMenuItem}
      function NewLine(Next: PMenuItem): PMenuItem;
               {Creeaza o linie "SEPARTOR" }
      function NewSubMenu(Name: TMenuStr; AHelpCtx: Word; SubMenu: PMenu; Next: PMenuItem): PMenuItem;
               {creeaza un nou submeniu}
      procedure DrawMenu(Menu:PMenu;x,y:word);
               {deseneaza meniul Menu la (x;y)}
      procedure DisposeMenu(Menu: PMenu);
               {Elibereaza memoria alocata pentru un meniu}
{ - Start Menu -}
procedure StartPoint;

{--------========----------} Implementation {--------========---------}


{PString implementation}

function NewStr(const S: String): PString;
var
  P: PString;
begin
  if S = '' then P := nil else
  begin
    GetMem(P, Length(S) + 1);
    P^ := S;
  end;
  NewStr := P;
end;(*NewStr*)


procedure DisposeStr(P: PString);
begin
  if P <> nil then FreeMem(P, Length(P^) + 1);
end;(*DisposeStr*)

{ TMenu routines }

function NewItem(Name: TMenuStr; Command: Word;AHelpCtx: Word; Next: PMenuItem): PMenuItem;
var
  P: PMenuItem;
begin
  if (Name <> '') and (Command <> 0) then
  begin
    New(P);
    P^.Next := Next;
    P^.Name := NewStr(Name);
    P^.Command := Command;
    P^.SubMenu := nil;
    P^.HelpCtx := AHelpCtx;
    NewItem := P;
  end else
  NewItem := Next;
end;(*NewItem*)


function NewLine(Next: PMenuItem): PMenuItem;
var
  P: PMenuItem;
begin
  New(P);
  P^.Next := Next;
  P^.Name := nil;
  P^.SubMenu := nil;
  P^.HelpCtx := hcNoContext;
  NewLine := P;
end;(*NewLine*)


function NewSubMenu(Name: TMenuStr; AHelpCtx: Word; SubMenu: PMenu; Next: PMenuItem): PMenuItem;
var
  P: PMenuItem;
begin
  if (Name <> '') and (SubMenu <> nil) then
  begin
    New(P);
    P^.Next := Next;
    P^.Name := NewStr(Name);
    P^.Command := 0;
    P^.Disabled := False;
    P^.HelpCtx := AHelpCtx;
    P^.SubMenu := SubMenu;
    NewSubMenu := P;
  end else
  NewSubMenu := Next;
end;(*NewSubMenu*)


function NewMenu(Items: PMenuItem): PMenu;
var
  P: PMenu;
begin
  New(P);
  P^.Items := Items;
  NewMenu := P;
end; (*NewMenu*)


procedure DisposeMenu(Menu: PMenu);
var
  P, Q: PMenuItem;
begin
  if Menu <> nil then
  begin
    P := Menu^.Items;
    while P <> nil do
    begin
      if P^.Name <> nil then
      begin
        DisposeStr(P^.Name);
        if P^.Command = 0 then
          DisposeMenu(P^.SubMenu);
      end;
      Q := P;
      P := P^.Next;
      Dispose(Q);
    end;
    Dispose(Menu);
  end;
end;(*DisposeMenu*)


procedure DrawMenuName(S:TMenuStr;xx,yy:word);
var i:word;
begin
for i:=1 to length(s) do
 if s[i]<>'&' then
  begin
    outtextxy(xx,yy,s[i]);
    inc(xx,TextWidth('M'));
  end
 else
  begin
    line (xx,yy+TextHeight(s[i]),xx+TextWidth(s[i])-2,yy+TextHeight(s[i]));
  end;
end;(*DrawMenuName*)


procedure DrawMenu(Menu:PMenu;x,y:word);
var P : PMenuItem;
begin
SetColor(0);
SetTextStyle(0,0,1);
P := Menu^.items;
 while (P <> nil) do
   begin
     DrawMenuName( P^.name^, x, y);
     inc(x,TextWidth(P^.name^)+2);
     P := P^.next;
   end;
end;(*DrawMenu*)

procedure InitCRCBoxFiles(wndId:byte); 
var f:file;
begin
assign(f,'wnd'+int2str(wndid)+'.tmp');
rewrite(f,1);
close(f)
end;

procedure EraseCRCBoxFiles(wndId:byte);
var f:file;
begin
assign(f,'wnd'+int2str(wndid)+'.tmp');
erase(f);
end;


procedure UpDateMemoryCRCBox(wndid,CeckBoxId,RadioBoxId:byte);
var cb_buf : array[1..$20] of char;
    ch:char;
    o:byte;
    f:file;
    id,i:byte;
    sel_rb:byte;
    cr,rr:boolean;
begin
assign(f,'wnd'+int2str(wndid)+'.tmp');
reset(f,1);
cr:=false;rr:=false;
while not(eof(f)) do
 begin
    BlockRead(f,ch,1);o:=ord(ch);
    case ((o and (3 shl 6)) shr 6) of
          $01 : begin  {ceckbox}
                      BlockRead(f,ch,1);
                      id:=ord(ch);
                      FillChar(cb_buf,$20,0);
                      BlockRead(f,cb_buf,(o and $3F));
                      if id=CeckBoxId then
                       begin
                        for i:=1 to $20 do
                          cbl[i]:=ord(cb_buf[i]);
                        cr:=true;
                       end;
                end;
      $02,$03 : begin  {radiobox}
                      BlockRead(f,ch,1);
                      id:=ord(ch);
                      BlockRead(f,ch,1);
                      if id=RadioBoxId then
                       begin
                        SelectedRadioBox:=ord(ch);
                        rr:=true;
                       end;
                end;
    end;
 end;

if CeckBoxId<>0 then
  if cr=false then
     for i:=1 to $20 do cbl[i]:=0;

if RadioBoxId<>0 then
  if rr=false then
     SelectedRadioBox:=0;

close(f);
end;

procedure UpDateFileCRCBox(wndid,CeckBoxId,RadioBoxId:byte);
var cb_buf : array[1..$20] of char;
    f,fb:file;
    i,o,id:byte;brd:word;
    ch:char;cr,rr:boolean;

    function getlcbl:byte;
    var i,l:byte;
    begin
    l:=1;
         for i:=$20 downto 1 do
           if cbl[i]<>0 then l:=i;
    getlcbl:=l;
    end;

begin
copyfile('wnd'+int2str(wndid)+'.tmp','wnd'+int2str(wndid)+'.bak');
assign(f ,'wnd'+int2str(wndid)+'.tmp');rewrite(f,1);
assign(fb,'wnd'+int2str(wndid)+'.bak');reset(fb,1);
cr:=false;
rr:=false;

while not(eof(fb)) do
 begin
    BlockRead(fb,ch,1);o:=ord(ch);

    case ((o and (3 shl 6)) shr 6) of
          $01 : begin {ceckbox}
                      ch:=chr( (1 shl 6) or getlcbl);
                      BlockWrite(f,ch,1);
                      BlockRead(fb,ch,1);
                      BlockWrite(f,ch,1);
                      id:=ord(ch);
                      FillChar(cb_buf,$20,0);
                      BlockRead(fb,cb_buf,(o and (not (3 shl 6))));
                      if id=CeckBoxId then
                       begin
                             for i:=1 to getlcbl do
                               if cbl[i]<>ord(cb_buf[i]) then
                                   cb_buf[i]:=chr(cbl[i]);
                             cr:=true;
                       end;
                      BlockWrite(f,cb_buf,getlcbl);
                end;
      $02,$03 : begin {radiobox}
                      BlockWrite(f,ch,1);
                      BlockRead(fb,ch,1);
                      BlockWrite(f,ch,1);
                      id:=ord(ch);
                      BlockRead(fb,ch,1);
                      if id=RadioBoxId then
                       begin
                        ch:=chr(SelectedRadioBox);
                        rr:=true;
                       end;
                      BlockWrite(f,ch,1);
                end;
    end;
 end;

if CeckBoxId<>0 then
    if cr=false then begin
                            ch:=chr( (1 shl 6) or getlcbl);
                            BlockWrite(f,ch,1);
                            ch:=chr(CeckBoxId);
                            BlockWrite(f,ch,1);
                            for i:=1 to getlcbl do
                               begin
                                 ch:=chr(cbl[i]);
                                 BlockWrite(f,ch,1);
                               end;
                     end;
if RadioBoxId<>0 then
    if rr=false then begin  ch:=chr($81);
                            BlockWrite(f,ch,1);
                            ch:=chr(RadioBoxId);
                            BlockWrite(f,ch,1);
                            ch:=chr(SelectedRadioBox);
                            BlockWrite(f,ch,1);
                     end;

close(f);erase(fb);close(fb);
end;

procedure CleanTempFiles;
var i:byte;
    f:file;
begin
  for i:=1 to 255 do
   begin
     assign(f,'wnd'+int2str(i)+'.tmp');
     if FileExists('wnd'+int2str(i)+'.tmp') then erase(f) else exit;
   end;
end;

procedure HandleClock;
var h,m,sec,sut:word;
    s,s1,s2:string;
    q:boolean;
   cp:PointType;
begin
  with cp do
      begin
       X:=getmaxx-67;
       y:=getmaxy-16;
      end;

     settextstyle(0,0,1);
     gettime(h,m,sec,sut);
     if h>12 then begin h:=h-12;s2:='PM';end else s2:='AM';
     if m<>newmin then
        begin
             q:=mouse_on(getmaxx-68,getmaxy-23,getmaxx-2,getmaxy-3);
             str(h,s);
             str(m,s1);
             if h<10 then s:= ' ' + s;
             if m<10 then
             begin
                          if q then mouse.hideMouseCursor;
                          setfillstyle(1,7);
                          bar(getmaxx-68,getmaxy-23,getmaxx-2,getmaxy-3);
                          setcolor(0);
                          outtextxy(cp.x,cp.y,s+':0'+s1+' '+s2);
                          rectangle3d(getmaxx-68,getmaxy-23,getmaxx-2,getmaxy-3,8,15);
                          if q then mouse.showMouseCursor;
             end
                       else
             begin
                          if q then mouse.hideMouseCursor;
                          setfillstyle(1,7);
                          bar(getmaxx-68,getmaxy-23,getmaxx-2,getmaxy-3);
                          setcolor(0);
                          outtextxy(cp.x,cp.y,s+':'+s1+' '+s2);
                          rectangle3d(getmaxx-68,getmaxy-23,getmaxx-2,getmaxy-3,8,15);
                          if q then mouse.showMouseCursor;
             end;
             newmin:=m;
        end;
TaskSwitch;
end;(*HandleClock*)

procedure DrawAppOnBar(x:byte;name:string;active:boolean);
var i,nc,c:byte;
    maxy:word;
const b=55;
begin
mouse.hideMouseCursor;
maxy:=getmaxy;
if active then
  begin
   SetFillPattern(Patterns[DesktopFillPatern],7);
   bar(b+MAL*(x-1)+dal,maxy-22,b+MAL*x-dal,maxy-5);
   NewRectangle3d(b+MAL*(x-1)+dal,maxy-22,b+MAL*x-dal,maxy-5,8,15,8,15);
   load_iconWin16(b+mal*(x-1)+dal+1,maxy-22+1+16-1,'Point.ico');
   setcolor(15)
  end
          else
  begin
  SetFillStyle(1,7);
  bar(b+MAL*(x-1)+dal,maxy-22,b+MAL*x-dal,maxy-5);
  NewRectangle3d(b+MAL*(x-1)+dal,maxy-22,b+MAL*x-dal,maxy-5,15,8,15,8);
  load_iconWin16(b+mal*(x-1)+dal+1,maxy-22+16-1,'Point.ico');
  setcolor(8)
  end;

settextstyle(0,0,1);c:=0;
nc:=TextWidth('M');
if (TextWidth(name)+2*3+16 < Mal) then
   outtextxy(5+16+b+mal*(x-1)+dal,maxy-22+5,name)
                               else
   begin
    for i:=1 to (((mal-2*3-16) div nc))-3 do
     begin
      outtextxy(16+5+b+mal*(x-1)+dal+c,maxy-22+5,name[i]);
      inc(c,nc);
    end;
    outtextxy(5+16+b+mal*(x-1)+dal+c-1,maxy-22+5,'...');
  end;
mouse.showMouseCursor;
end;(*DrawAppOnBar*)

procedure DrawTextFrame(TxFile:String;x1,y1:word;Width,Height:byte;edit:boolean);
var x2,y2:word;
    nx,ny:byte;
    ch:char;
    f:file of char;
begin
 x2:=x1+ Width*8;
 y2:=y1+Height*8;
 SetFillStyle(1,7);
 Bar(x1-3,y1-3,x2+3,y2+3);
if edit then
begin
 NewRectangle3d(x1,y1,x2,y2,0,7,8,15);
 SetFillStyle(1,15);
 Bar(x1,y1,x2,y2);
end else Rectangle3d(x1,y1,x2,y2,8,15);
 setcolor(0);
 settextstyle(0,0,0);

nx:=0;ny:=0;
  assign(f,TxFile);
  reset(f);
  repeat
      read(f,ch);

      if (ch>=chr($20)) then outtextxy(x1+(nx)*8+1,y1+(ny)*8+1,ch);

      if (nx<>0) and ((nx+1=Width) or (ch=Chr($D)))
                                    then begin
                                            nx:=0;
                                            inc(ny,1);
                                         end
                                    else
                                     if (ch>=chr($20)) then inc(nx,1);

   until (eof(f)) or (ny=Height);
    close(f)
end;

procedure DrawRadioBox(x,y:word;q:boolean);
begin
HideMouseCursor;
y:=y+4;
setfillstyle(1,7);
fillellipse(x,y,5,5);
setcolor(8);
circle(x,y,5);
if q then
begin
  setcolor(14);
  setfillstyle(1,14);
  FillEllipse(x,y,2,2);
end;
ShowMouseCursor;
end;(*DrawRadioBox*)

procedure DrawCeckBox(x,y:word;q:boolean);
begin
HideMouseCursor;
 setcolor(8);
 setfillstyle(1,7);
 bar(x+1,y+1,x+9,y+9);
 rectangle(x,y,x+10,y+10);
  if q then
   begin
     setcolor(14);
     line(x+1,y+1,x+10-1,y+10-1);
     line(x+10-1,y+1,x+1,y+10-1);
   end;
ShowMouseCursor;
end;(*DrawCeckBox*)

procedure DrawWindowControls(wnd:PWindow);
var fi:file;
    b:boolean;
    ch:char;
    s:string;
    o,i,ns:byte;
    w,yy:word;
   but:ButtonClass;
   lst:ListClass;
   inp:InputClass;
begin
Mouse.HideMouseCursor;
with Wnd^ do
if Wnd^.menu =  nil then
 begin
   assign(fi,ResourceF);  reset(fi,1);
   if state<>maximized then
   With WindowPos do SetViewPort( x1+2, y1+2, x2-2, y2-2, ClipOn)
                       else
   With DeskTop_pos do SetViewPort(x1+2,y1+2,x2-2,y2-30,ClipOn);

  ocb:=0;b:=false;
  while (not eof(fi)) do
  begin
       BlockRead(fi,ch,1);
       o:=ord(ch);  ocb:=o and $3f;  o:=o shr 6;

       case o of
            0 : begin
                      BlockRead(fi,ch,1);
                      case ocb     of
                         bp_Window                : b:=(ord(ch)=wnd^.id);
                         bp_Window or bp_Button   : but.id:=ord(ch);
                         bp_Window or bp_Input    : inp.id:=ord(ch);
                         bp_Window or bp_CeckBox  : lst.id:=ord(ch);
                         bp_Window or bp_RadioBox : lst.id:=ord(ch);
                         bp_Window or bp_ComboBox : lst.id:=ord(ch);
                      end;
                end;
            1 : begin
                      w:=0;
                      for i:=1 to 4 do
                       begin
                         BlockRead(fi,ch,1);
                         case i of
                             1,3 : w:=ord(ch) shl 8;
                             2,4 : begin
                                    w:=w or ord(ch);
                                         case ocb     of
                                            bp_Window or bp_CeckBox  : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                            bp_Window or bp_RadioBox : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                            bp_Window or bp_ComboBox : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                         end;
                                   yy:=w;w:=0;ns:=0;  {ww <-- y}
                                   end;
                         end;
                       end;

                end;
            2 : begin
                      w:=0;
                      for i:=1 to 8 do
                       begin
                         BlockRead(fi,ch,1);
                         if b then
                         case i of
                          1,3,5,7 : w:=ord(ch) shl 8;
                          2,4,6,8 : begin
                                     w:=w or ord(ch);
                                       case ocb of
                                          bp_Window or bp_Button : with but.position do
                                                                        case i of
                                                                             2 : x1:=w;
                                                                             4 : y1:=w;
                                                                             6 : x2:=w;
                                                                             8 : y2:=w;
                                                                        end;
                                          bp_Window or bp_Input  : with inp do
                                                                        case i of
                                                                             2 : insertpoint.x:=w;
                                                                             4 : insertpoint.y:=w;
                                                                             6 : MaxXChar:=w;
                                                                             8 : MAxYChar:=w;
                                                                        end;
                                       end;
                                     w:=0;
                                   end;
                         end;
                       end;
                end;
            3 : begin
                      BlockRead(fi,ch,1);s:='';
                      for i:=1 to ord(ch) do
                       begin
                        BlockRead(fi,ch,1);
                        s:=s+ch;
                       end;
                      if b then
                      case ocb of
                         bp_Window or bp_Button  : with but,but.position do
                                                     DrawButton(x1, y1, x2, y2, s,0,false);
                         bp_Window or bp_Input   : with inp,inp.insertpoint do
                                                     DrawTextFrame(s,x,y,MaxXChar,MaxYChar,true);
                         bp_Window or bp_CeckBox : with lst do
                                                     begin
                                                     with insertpoint do
                                                     begin
                                                      ns:=ns+1;
                                                      {UpDateMemoryCRCBox(wnd^.id,lst.id,0);...is implemented below}
                                                      DrawCeckBox(x,yy,SelectedCeckBoxElement(wnd^.id,lst.id,ns));
                                                      setcolor(0);
                                                      Outtextxy(x+15,yy+2,s);
                                                     end;
                                                      yy:=yy+TextHeight('M')+5;
                                                     end;
                         bp_Window or bp_RadioBox: with lst do
                                                     begin
                                                     with insertpoint do
                                                     begin
                                                      ns:=ns+1;
                                                      UpDateMemoryCRCBox(wnd^.id,0,lst.id);
                                                      DrawRadioBox(x,yy,SelectedRadioBox=ns);
                                                      setcolor(0);
                                                      Outtextxy(x+15,yy+2,s);
                                                     end;
                                                      yy:=yy+TextHeight('M')+5;
                                                     end;
                      end;
                end;
       end;
  end;
  close(fi);
  SetViewPort( 0, 0, GetMaxX, GetMaxY, ClipOn);
 end;
Mouse.ShowMouseCursor;
end;(*DrawWindowControls*)


procedure DrawButton(x,y,xx,yy :word;caption :string;_color:byte;click:boolean);
var
  hor,ver :real;
  P:INTEGER;
  rand,p1,p2,p3:byte;
  _icon:string;
begin
HideMouseCursor;
rand:=1;
setfillstyle(1,7);
bar(x,y,xx,yy);
p1:=Pos('<',caption);
p2:=Pos('.',caption);
p3:=Pos('>',caption);
if (p1>0)and(p2>0)and(p3>0)and(p1<p2)and(p1<p3)and(p2<p3) then
      begin
             _icon:='';
             for p:= p1+1 to p3-1 do
               _icon:=_icon+caption[p];
             {  load_iconWin16(xx div 2,yy,_icon);}
             Delete(caption,p1,p3-p1+1);
      end;
  setcolor(15);
  if click then  setcolor(8);
  for p :=0 to rand do line(x+p,y+p,xx-p,y+p);
  for p :=0 to rand do line(x+p,y+p,x+p,yy-p);
  setcolor(8);
  if click then  setcolor(15);
  for p :=0 to rand do line(x+p,yy-p,xx-p,yy-p);
  for p :=0 to rand do line(xx-p,y+p,xx-p,yy-p);
  settextstyle(2,0,6);
  hor :=((xx-x)/2)+x-(length(caption)*10)/2;ver :=((yy-y)/2)+y-5;
  if click then begin hor:=hor+1;ver:=ver+1;end;
  setcolor(_color);outtextxy(round(hor)+1,round(ver)-5,caption);
  setcolor(_color);outtextxy(round(hor)+2,round(ver)-5,caption);
  settextstyle(0,0,1);
ShowMouseCursor;
end;(*DrawButton*)

procedure NewButton(Nr:byte;x1,y1,x2,y2:word; Caption:String);
begin
if mouse_on(x1,y1,x2,y2)and(LeftButton) then
   begin
              DrawButton(x1,y1,x2,y2,Caption,0,true);
                 repeat
                     if (not Mouse_on(x1,y1,x2,y2)) then
                         begin
                              DrawButton(x1,y1,x2,y2,Caption,0,false);
                              repeat
                               HandleClock;
                              until mouse_on(x1,y1,x2,y2)or(Not LeftButton);
                              if Mouse_on (x1,y1,x2,y2) then DrawButton(x1,y1,x2,y2,Caption,0,true)
                         end;
                  HandleClock;
                 until (not LeftButton);
                 DrawButton(x1,y1,x2,y2,Caption,0,false);
             if Mouse_on(x1,y1,x2,y2) then SelectedButton:=Nr
                                      else SelectedButton:=$00;
   end;
end;(*NewButton*)

procedure ClkOnRadioBox(x,y:word;q:boolean);
begin
HideMouseCursor;
setcolor(14);
setfillstyle(1,14);
fillellipse(x,y,5,5);
setfillstyle(1,7);
fillellipse(x,y,4,4);
setfillstyle(1,14);
if q then   FillEllipse(x,y,2,2);
ShowMouseCursor;
end;(*ClkOnRadioBox*)


procedure NewRadioBox(Nr:byte;x,y:word; Caption:String);
var x2,y2:word;
    b:boolean;
begin
x:=x-5;y:=y-5;
x2:=x+TextWidth(Caption)+15;
y2:=y+TextHeight('M')+4;
b:=(SelectedRadioBox=Nr);
if mouse_on(x,y,x2,y2)and(LeftButton) then
   begin
              ClkOnRadioBox(x+5,y+5,b);
                 repeat
                     if (not Mouse_on(x,y,x2,y2)) then
                         begin
                              if b then ClkOnRadioBox(x+5,y+5,not b)
                                   else DrawRadioBox(x+5,y+1,b);
                              repeat
                               HandleClock;
                              until mouse_on(x,y,x2,y2)or(Not LeftButton);
                              if Mouse_on (x,y,x2,y2) then ClkOnRadioBox(x+5,y+5,b);
                         end;
                  HandleClock;
                 until (not LeftButton);
                 ClkOnRadioBox(x+5,y+5,b);
             if Mouse_on(x,y,x2,y2) then SelectedRadioBox:=Nr
   end;
end;(*NewRadioBox*)


procedure ClickOnCeckBox(x,y:word;q:boolean);
begin
hidemousecursor;
if q then
begin
setcolor(14);
rectangle(x,y,x+10,y+10);
rectangle(x+1,y+1,x+9,y+9);
end else
begin
setcolor(8);
setfillstyle(1,7);
bar(x,y,x+10,y+10);
rectangle(x,y,x+10,y+10);
end;
showmousecursor;
end;(*ClickOnCeckBox*)


procedure NewCeckBox(Nr:byte;x,y:word; Caption:String);
var x2,y2:word;
    bit:byte;
begin
x:=x-5;y:=y-5;
x2:=x+TextWidth(Caption)+15;
y2:=y+TextHeight('M')+4;
bit:=GetBit(CBL[getbyteNo(nr)],getbitno(nr));
SelectedCeckBox:=$FF;
if mouse_on(x,y,x2,y2)and(LeftButton) then
   begin
                ClickOnCeckBox(x+5,y+1,true);
                 repeat
                     if (not Mouse_on(x,y,x2,y2)) then
                         begin
                              ClickOnCeckBox(x+5,y+1,false);
                              repeat
                               HandleClock;
                              until mouse_on(x,y,x2,y2)or(Not LeftButton);
                              if Mouse_on (x,y,x2,y2) then ClickOnCeckBox(x+5,y+1,true);
                         end;
                  HandleClock;
                 until (not LeftButton);
                 ClickOnCeckBox(x+5,y+1,false);
             if Mouse_on(x,y,x2,y2) then
               if bit=0 then begin SelectedCeckBox:=Nr;
                                   DrawCeckBox(x+5,y+1,true);
                             end
                        else begin
                                   SelectedCeckBox:=0;
                                   DrawCeckBox(x+5,y+1,false);
                             end
            else if bit = 1 then DrawCeckBox(x+5,y+1,true);

   end;
end;(*NewCeckBox*)


function SelectedCeckBoxElement(wnd_id,cb_id,nr:byte):boolean;
var xbyte,xbit:byte;
begin
     UpDateMemoryCRCBox(wnd_id,cb_id,0);
     SelectedCeckBoxElement:=(GetBit(CBL[getbyteno(nr)],getbitno(nr))=1);
end;(*SelectedCeckBoxElement*)


procedure HandleWindowsControls(Wnd:PWindow);
var fi:file;
    b,rdrw:boolean;
    ch:char;
    s:string;
    o,i,ns,nb,pp:byte;
    w,yy:word;
   but:ButtonClass;
   lst:ListClass;
   inp:InputClass;
begin
with Wnd^ do
if Wnd^.menu =  nil then
 begin
   assign(fi,ResourceF);  reset(fi,1);
   ocb:=0;b:=false;rdrw:=false;
  while (not eof(fi)) do
  begin
       BlockRead(fi,ch,1);
       o:=ord(ch);
       for i:=1 to 6 do
         begin
           if (i=5)and(getbit(ocb,i-1)=1)and(getbit(o,i-1)=0)and(b) then
             UpDateMemoryCRCBox(wnd^.id,0,lst.id);
         end;
       ocb:=o and $3f;  o:=o shr 6;
       case o of
            0 : begin
                      BlockRead(fi,ch,1);
                      case ocb     of
                         bp_Window                : b:=(ord(ch)=id); {<--}
                         bp_Window or bp_Button   : but.id:=ord(ch);
                         bp_Window or bp_Input    : inp.id:=ord(ch);
                         bp_Window or bp_CeckBox  : begin
                                                     lst.id:=ord(ch);
                                                     UpDateMemoryCRCBox(wnd^.id,lst.id,0);
                                                    end;
                         bp_Window or bp_RadioBox : begin
                                                     lst.id:=ord(ch);
                                                     UpDateMemoryCRCBox(wnd^.id,0,lst.id);
                                                    end;
                         bp_Window or bp_ComboBox : lst.id:=ord(ch);
                      end;
                end;
            1 : begin
                      w:=0;
                      for i:=1 to 4 do
                       begin
                         BlockRead(fi,ch,1);
                         case i of
                             1,3 : w:=ord(ch) shl 8;
                             2,4 : begin
                                    w:=w or ord(ch);
                                         case ocb     of
                                            bp_Window or bp_CeckBox  : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                            bp_Window or bp_RadioBox : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                            bp_Window or bp_ComboBox : with lst.insertpoint do
                                                                             case i of
                                                                                  2  : x:=w;
                                                                                  4  : y:=w;
                                                                             end;
                                         end;
                                   yy:=w;w:=0;ns:=0;nb:=8;pp:=1;  {ww <-- y}
                                   end;
                         end;
                       end;

                end;
            2 : begin
                      w:=0;
                      for i:=1 to 8 do
                       begin
                         BlockRead(fi,ch,1);
                         if b then
                         case i of
                          1,3,5,7 : w:=ord(ch) shl 8;
                          2,4,6,8 : begin
                                     w:=w or ord(ch);
                                       case ocb of
                                          bp_Window or bp_Button : with but.position do
                                                                        case i of
                                                                             2 : x1:=w;
                                                                             4 : y1:=w;
                                                                             6 : x2:=w;
                                                                             8 : y2:=w;
                                                                        end;
                                          bp_Window or bp_Input  : with inp do
                                                                        case i of
                                                                             2 : insertpoint.x:=w;
                                                                             4 : insertpoint.y:=w;
                                                                             6 : MaxXChar:=w;
                                                                             8 : MAxYChar:=w;
                                                                        end;
                                       end;
                                     w:=0;
                                   end;
                         end;
                       end;
                end;
            3 : begin
                      BlockRead(fi,ch,1);s:='';
                      for i:=1 to ord(ch) do
                       begin
                        BlockRead(fi,ch,1);
                        s:=s+ch;
                       end;
                      if b then
                      case ocb of
                         bp_Window or bp_Button  : begin
                                                   with but,but.position do
                                                    if state<>maximized then
                                                    NewButton(but.id,WindowPos.x1+x1+2,WindowPos.y1+y1+2,WindowPos.x1+x2+2,
                                                    WindowPos.y1+y2+2,s)
                                                    else
                                                    NewButton(but.id,DeskTop_pos.x1+x1+2,DeskTop_pos.y1+y1+2,
                                                    DeskTop_pos.x1+x2+2,DeskTop_pos.y1+y2+2,s);
                                                    if SelectedButton <> $00 then WinButtons:=wnd^.id;
                                                   end;
{                        bp_Window or bp_Input   : with inp,inp.insertpoint do
                                                     DrawTextFrame(s,x,y,MaxXChar,MaxYChar,true);}
                         bp_Window or bp_CeckBox : with lst,lst.insertpoint do
                                                   begin
                                                        ns:=ns+1;
                                                          if state<>maximized then
                                                          with WindowPos do
                                                           NewCeckBox(ns,x1+x+2,y1+yy+2+4,s)
                                                                              else
                                                          with DeskTop_Pos do
                                                           NewCeckBox(ns,x1+x+2,y1+yy+2+4,s);

                                                      if (SelectedCeckBox<>$FF) then
                                                          begin
                                                             cbl[pp]:=setbit(cbl[pp],nb-1,byte(SelectedCeckBox<>0));
                                                             UpDateFileCRCBox(wnd^.id,lst.id,0);
                                                          end;
                                                                dec(nb,1);
                                                                if nb=0 then begin nb:=8;
                                                                                   inc(pp,1);
                                                                             end;
                                                       yy:=yy+TextHeight('M')+5;
                                                     end;
                         bp_Window or bp_RadioBox: with lst do
                                                     begin
                                                     with insertpoint do
                                                     if not rdrw then
                                                     begin
                                                        ns:=ns+1;
                                                        SelectedRadioBox:=0;
                                                          if state<>maximized then
                                                          with WindowPos do
                                                           NewRadioBox(ns,x1+x+2,y1+yy+2+4,s)
                                                                              else
                                                          with DeskTop_Pos do
                                                           NewRadioBox(ns,x1+x+2,y1+yy+2+4,s);

                                                      if (SelectedRadioBox=ns) then
                                                          begin
                                                                reset(fi,1);ocb:=0; b:=false; rdrw:=true;
                                                                UpDateFileCRCBox(wnd^.id,0,lst.id);
                                                          end;

                                                     end
                                                     else begin
                                                           ns:=ns+1;
                                                           if state<>maximized then
                                                          with WindowPos do
                                                           DrawRadioBox(lst.insertpoint.x+x1+2,yy+2+y1,
                                                           SelectedRadioBox=ns)
                                                                              else
                                                          with DeskTop_Pos do
                                                           DrawRadioBox(lst.insertpoint.x+x1+2,yy+2+y1,
                                                           SelectedRadioBox=ns);
                                                          end;
                                                           yy:=yy+TextHeight('M')+5;
                                                     end;
                      end;
                end;
       end;
  end;
  close(fi);
 end;
end;(*HandleWindowsControls*)


function GetWindowFlag(win:PWindow;Flt:FLTypes):boolean;
var k:byte;
begin
     case FLT of
      closeFlag    : k:=0;
      minimizeFlag : k:=1;
      maximizeFlag : k:=2;
     end;
    GetWindowFlag:=(GetBit(win^.flags,k)=1);
end;

procedure DrawWindow(win:PWindow);
var x1,y1,x2,y2:word;
begin
with win^ do
begin
if state<>maximized then begin
                               x1:=WindowPos.x1;
                               y1:=WindowPos.y1;
                               x2:=WindowPos.x2;
                               y2:=WindowPos.y2;
                         end
                    else begin
                               x1:=Desktop_pos.x1+1;
                               y1:=Desktop_pos.y1+1;
                               x2:=Desktop_pos.x2-1;
                               y2:=Desktop_pos.y2-30;
                         end;
   mouse.hideMouseCursor;
   {the main part}
   SetFillStyle(1,7);
   Bar(x1,y1,x2,y2);
   Rectangle3d(x1,y1,x2,y2,White,DarkGray);
   {title bar}
   setColor(15); setfillstyle(1,1);
   if ActiveWnd<>id then begin Setcolor(7);setfillstyle(1,8);end;
   bar(x1+3,y1+3,x2-3,y1+15+3);
   settextstyle(2,0,5);
   outtextxy(x1+4+20,y1+2,Name^);
   load_iconWin16(x1+3,y1+2+16,'quick.ico');
   {Put_wdICON(x1+3,y1+3);}
   {buttons}
   setfillstyle(1,7);
   {close}
   bar(x2-13,y1+5+1,x2-4,y1+14+1);
   Rectangle3d(x2-13,y1+5+1,x2-4,y1+14+1,White,DarkGray);
   if GetWindowFlag(win,closeFlag) then SetColor(0) else SetColor(8);
   settextstyle(11,0,1);
   outtextxy(x2-12,y1+6,'X');
   {maximize}
   bar(x2-25,y1+5+1,x2-16,y1+14+1);
   Rectangle3d(x2-25,y1+5+1,x2-16,y1+14+1,White,DarkGray);
   if GetWindowFlag(win,maximizeFlag) then SetColor(0) else Setcolor(8);
   settextstyle(11,0,1);
   outtextxy(x2-24,y1+5+1,'þ');
   {minimize}
   bar(x2-37,y1+5+1,x2-28,y1+14+1);
   Rectangle3d(x2-37,y1+5+1,x2-28,y1+14+1,White,DarkGray);
   if GetWindowFlag(win,minimizeFlag) then SetColor(0) else SetColor(8);
   settextstyle(11,0,1);
   outtextxy(x2-37,y1+5+1,'_');
if WType = application then
   begin
    setfillstyle(1,8);
    newrectangle3d(x1+6,y1+20+15+2,x2-6,y2-5,DarkGray,White,Black,LightGray);
    bar(x1+6,y1+20+15+2,x2-6,y2-6);
    DrawMenu(Menu,x1+7,y1+22);                 {drawing the menu}
   end;
   mouse.showMouseCursor;
end;
end;(*DrawWindow*)

function GetWindow(nr:byte):PWindow;
var c:PWindow;
begin
 c:=PWin;
 while (nr<>c^.id)and(c<>nil) do
    begin
      c:=c^.next;
    end;
 GetWindow:=c;
end;(*GetWindow*)

function  GetWindowZ(Cz:byte):byte;
var p:PWindow;
begin
    p:=PWin;
     while (p<>nil)and(p^.Z<>Cz) do
       p:=p^.next;
  if p=nil then GetWindowZ:=0
           else GetWindowZ:=p^.id;
end;(*GetWindowZ*)

function WindowExist(nr:byte):boolean;
begin
  WindowExist:=(GetWindow(nr) <> nil);
end;(*Window_Exist*)

function MenuExist(nr:byte):boolean;
var p:PWindow;
    b:boolean;
begin
b:=false;
p:=GetWindow(nr);
if (p<>nil) then
      if (p^.menu <> nil) then b:=true;
MenuExist:=b;
end;(*MenuExist*)

procedure OpenWindow(Nr:byte;_pos:TWindowPosition;title:string;tip:wnd_type;NMenu:Pmenu);
var c,p:PWindow;
    cz:word;
           function GetLastWindow:PWindow;
            var p:PWindow;
            begin
              p:=PWin;
              while (p^.next<>nil) do
                   p:=p^.next;
              GetLastWindow:=p;
            end;

begin
for cz:=1 to 32 do CBL[cz]:=0;
if LA > MaxWindowZ then MaxWindowZ:=LA;
ActiveWnd:=nr;
 if PWin=nil
 then
  begin
      New(PWin);
      with PWin^ do
       begin
          Name:=NewStr(title);
      WindowPos:=_pos;
          state:=normal;
          wtype:=tip;
          max:=false;
          xbar:=LA;
          Menu:=NMenu;
          next:=nil;
          id:=nr;
          Z:=LA;cz:=z;
       end;
      DrawAppOnBar(LA,title,true);
      if (LA mod 5) = 0 then  MAL:=MAL div 2;
      inc(LA,1);
   end
 else
if GetWindow(nr) = nil
 then
  begin
      New(c);
      p:=GetLastWindow;
      p^.next:=c;
      with c^ do
      begin
         Name:=NewStr(title);
      WindowPos:=_pos;
          state:=normal;
          wtype:=tip;
          max:=false;
          xbar:=LA;
          Menu:=NMenu;
          next:=nil;
          id:=nr;
          Z:=LA;cz:=z;
      end;
      DrawAppOnBar(LA,title,true);
      if (LA mod 5) = 0 then  MAL:=MAL div 2;
      inc(LA,1);
  end;

refresh:=false;
    p:=PWin;
end;(*OpenWindow*)

procedure LoadWindow(ResF:string;nr,Wid:byte;NMenu:Pmenu);
var c,p,x:PWindow;
    g:WindowClass;
    cz:word;
            function GetLastWindow:PWindow;
            var p:PWindow;
            begin
              p:=PWin;
              while (p^.next<>nil) do
                   p:=p^.next;
              GetLastWindow:=p;
            end;
begin
if FileExists(ResF) then
begin
for cz:=1 to 32 do CBL[cz]:=0;
if LA > MaxWindowZ then MaxWindowZ:=LA;
ActiveWnd:=Wid;
ImportWindow(nr,ResF,g);
if PWin=nil
 then
  begin
      New(PWin);
      with PWin^ do
      begin
          Name:=NewStr(g.Caption);
          id:=Wid;
        with WindowPos do
           begin
             x1:=g.position.x1;
             y1:=g.position.y1;
             x2:=g.position.x2;
             y2:=g.position.y2;
           end;
          state:=normal;
          max:=false;
          xbar:=LA;
          Menu:=NMenu;
          if Menu = nil then WType := dialog
                        else WType := application;
          next:=nil;
          Z:=LA;cz:=z;
          ResourceF:=ResF;
          SetWindowsFlagsOn(id, FLMinimize + FLMaximize + FLClose);
          InitCRCBoxFiles(Id);
       end;
      DrawAppOnBar(LA,PWin^.name^,true);
      if (LA mod 5) = 0 then  MAL:=MAL div 2;
      inc(LA,1);
   end
 else
if GetWindow(Wid) = nil
 then
  begin
      New(c);
      p:=GetLastWindow;
      p^.next:=c;
      with c^ do
      begin
          Name:=NewStr(g.Caption);
          id:=Wid;
        with WindowPos do
           begin
             x1:=g.position.x1;
             y1:=g.position.y1;
             x2:=g.position.x2;
             y2:=g.position.y2;
           end;
          state:=normal;
          max:=false;
          xbar:=LA;
          Menu:=NMenu;
          if Menu = nil then WType := dialog
                        else WType := application;
          next:=nil;
          Z:=LA;cz:=z;
          ResourceF:=ResF;
          SetWindowsFlagsOn(id, FLMinimize + FLMaximize + FLClose);
          InitCRCBoxFiles(Id);
       end;
      DrawAppOnBar(LA,c^.name^,true);
      if (LA mod 5) = 0 then  MAL:=MAL div 2;
      inc(LA,1);
   end;

refresh:=false;
    p:=PWin;
end else
           DebugBar(ErrorMsg(3));
end;(*LoadWindow*)

procedure SetWindowsFlagsOn(winId:byte;OFlag:byte);
var p:PWindow;
begin
        p:=GetWindow(winId);
        p^.Flags:=OFlag;
end;

procedure SetWindowsFlagsOff(winId:byte;OFlag:byte);
var p:PWindow;
begin
        p:=GetWindow(winId);
        p^.Flags:= ((not OFlag) and ($7));
end;


procedure NewImage(x1,y1,x2,y2:integer;var p:pointer;var size:word);
begin
Size:=ImageSize(x1,y1,x2,y2);
if MaxAvail < Size then
     DebugBar(ErrorMsg(4))
else
 begin
  GetMem(p,size);
  GetImage(x1,y1,x2,y2,p^);
 end;
end;(*NewImage*)


procedure DisposeImage(p:pointer;size:word);
begin
  FreeMem(p,size);
end;(*DisposeImage*)


procedure DisposeWindow(var lst:PWindow;nr:byte);
var p,c,d:PWindow;
    z0:word;
  procedure Delete_Wnd(var list:PWindow);
   var
      p, t: PWindow;
    begin
      p := list;
      t := p^.next^.next;
      if p^.next^.name<>nil then DisposeStr(p^.next^.name);
      dispose(p^.next);
      if p^.next^.menu<>nil then DisposeMenu(P^.next^.menu);
      p^.next := t;
    end;(*Delete_Wnd*)

begin
p:=lst;EraseCRCBoxFiles(GetWindow(nr)^.id);
if GetWindow(nr)<>nil then
if p^.id<>nr then
                 begin
                      while (p^.next<>nil)and(p^.next^.id<>nr) do p:=p^.next;
                      d:=p^.next;
                      Delete_Wnd(p);
                 end
             else
               if p^.next <> nil then
                 begin
                     c:=p;
                     lst:=p^.next;
                     if c^.menu<>nil then begin
                                           DisposeMenu(c^.Menu);
                                           c^.menu:=nil;
                                          end;
                     if c^.name<>nil then DisposeStr(c^.name);
                     Dispose(c);
                     d:=p;
                 end
                                 else  begin
                                        if lst^.menu<>nil then
                                           DisposeMenu(lst^.Menu);
                                        if lst^.Name<>nil then
                                           DisposeStr(lst^.Name);
                                         Dispose(lst);
                                        lst:=nil;d:=nil;
                                       end;
  while (d<>nil) do
   begin
      dec(d^.xbar,1);
      d:=d^.next;
   end;
      dec(La,1);
      dec(MaxWindowZ,1);
end;(*DisposeWindow*)

(*                     New Window procedure -- The "Ghost" Window Procedure                     *)
procedure NewWindow(Nr:byte);
var xi,yi,xf,yf:word;
    x0,y0:word;
    xd,yd:word;
    dx,dy:word;
    x1,y1,x2,y2:word;
    p1,p2,MBback:pointer;
    s1,s2:word;
    s:string;
    sem,bx,by:boolean;
    wnd:PWindow;
    mnu,pmi:PMenuItem;
    pw:PWindow;
    maxx,maxy:word;
{}


       function GetMenuItemMaxLengthX(pm:PMenuItem):word;
       var max:word;
           p:PMenuItem;
       begin
        p:=pm;
        max:=TextWidth(p^.Name^);
        while p <> nil do
         with p^ do
          begin
           if Name<>nil then
             if TextWidth(name^)>max then max:=TextWidth(name^);
           p:=p^.next;
          end;
       GetMenuItemMaxLengthX:=max;
       p:=nil;
       end;

       function GetMenuItemMaxLengthY(pm:PMenuItem):word;
       var max:word;
           p:PMenuItem;
       begin
        p:=pm;
        max:=0;
        while p<>nil do
         begin
           inc(max,TextHeight('M')+4);
           p:=p^.next;
         end;
       GetMenuItemMaxLengthY:=max;
       p:=nil;
       end;


       procedure wr_MenuItem(mi:PMenuItem;x,y,xf:word;selected:boolean);
       var c:byte;
           yf:word;
       begin
       mouse.hideMouseCursor;
       SetTextStyle(0,0,1);
       yf:=y+TextHeight('M')+2;
        if selected then
           begin
            setfillstyle(1,1);
            c:=15;
           end
         else
           begin
            setfillstyle(1,7);
            c:=0;
           end;
       bar(x,y,xf,yf);
       if mi^.name<>nil then begin
                               setcolor(c); DrawMenuName(mi^.Name^,x+2,y+2);
                             end
                        else begin
                               setcolor(8);
                               line(x+1,yf-((yf-y) div 2)-1,xf,yf-((yf-y) div 2)-1);
                               setcolor(15);
                               line(x+1,yf-((yf-y) div 2),xf,yf-((yf-y) div 2));
                             end;
       mouse.showMouseCursor;
       end;

       procedure PutMenuBox(mi:PMenuItem;xi,yi,xf:word;var img:pointer;var size:word);
       var p:PMenuItem;
           yf:word;
       begin
        p:=mi;
        yf:=yi+2;
        while p<>nil do
         begin
           inc(yf,TextHeight('M')+4);
           p:=p^.next;
         end;
        setfillstyle(1,7);
        NewImage(xi-3,yi-3,xf+3,yf+3,img,size);
        bar(xi-1,yi-1,xf+1,yf+1);
        newrectangle3d(xi-1,yi-1,xf+1,yf+1,15,8,15,0);
       end;


       procedure  UpDateMainBar(lista:PWindow);
       var c:PWindow;
           a:boolean;
       begin
         DrawMainBar;
         c:=lista;
         while (c<>nil) do
          begin
            with c^ do begin
                             a:=not (state=minimized);
                             DrawAppOnBar(xbar,name^,a)
                       end;
            c:=c^.next;
          end;
       end;

       function min_word(a,b:word):word;
       begin
        if a<b then min_word:=a else min_word:=b;
       end;

       function max_word(a,b:word):word;
       begin
        if a>b then max_word:=a else max_word:=b;
       end;

       procedure SuccWnd(var nr:byte);
       begin
       if nr=MaxWindowZ then nr := 1
                        else nr := nr + 1;
       end;



begin
wnd:=GetWindow(nr);
maxx:=GetMaxX;MaxY:=GetMaxY;
if wnd<>nil then
begin
with wnd^ do
if (mouse_on(55+MAL*(xbar-1)+dal,maxy-22,55+MAL*xbar-dal,maxy-5))and(LeftButton)
then
if (state=minimized) then
 begin
     refresh:=false;ActiveWnd:=nr;
     DrawAppOnBar(Xbar,Name^,true);
     if on_Sound then begin vawe(100,5);end;
     repeat
      HandleClock;
     until (not LeftButton)or(not mouse_on(55+MAL*(xbar-1)+dal,maxy-22,55+MAL*xbar-dal,maxy-5));
  if (mouse_on(55+MAL*(xbar-1)+dal,maxy-22,55+MAL*xbar-dal,maxy-5)) then
   with WindowPos do
     begin
       if max=false then state:=normal
                    else state:=maximized;

                                 if on_Sound then begin vawe(1900,5);end;
     end
   else
      begin
      DrawAppOnBar(xBar,Name^,false);
      if on_Sound then begin vawe(1200,5);end;
     end;
 end else if ActiveWnd<>nr then
          begin
              refresh:=false;ActiveWnd:=nr;
          end;


with wnd^ do
if (state=normal)or(state=maximized) then
 begin
if state<>maximized then begin x1:=WindowPos.x1;x2:=WindowPos.x2;
                               y1:=WindowPos.y1;y2:=WindowPos.y2;
                         end
                    else begin x1:=Desktop_pos.x1+1;x2:=Desktop_pos.x2-1;
                               y1:=Desktop_pos.y1+1;y2:=Desktop_pos.y2-30;
                         end;

   {begin of close wnd section}
if (GetWindowFlag(wnd,closeFlag)) and (mouse_on(x2-13,y1+5+1,x2-4,y1+14+1)and(LeftButton))
      or((indirect_close <> 0)and(indirect_close = nr))
   then
   if ActiveWnd=nr then
    begin
     if indirect_close=0 then
     begin
     mouse.hideMouseCursor;
     setfillstyle(1,7);
     bar(x2-13,y1+5+1,x2-4,y1+14+1);
     Rectangle3d(x2-13,y1+5+1,x2-4,y1+14+1,DarkGray,White);
     SetColor(0);
     settextstyle(11,0,1);
     outtextxy(x2-11,y1+6+1,'X');
     mouse.showMouseCursor;
     if on_Sound then begin vawe(1200,5);end;
     repeat
      HandleClock;
     until (not LeftButton);
     end;
       if mouse_on(x2-13,y1+1+5,x2-4,y1+14+1)or(indirect_close<>0)
         then
          begin
            if on_Sound then begin vawe(1900,5);end;
            mouse.hideMouseCursor;
            setfillstyle(1,7);
            bar(x2-13,y1+5+1,x2-4,y1+14+1);
            Rectangle3d(x2-13,y1+5+1,x2-4,y1+14+1,White,DarkGray);
            SetColor(0);
            outtextxy(x2-12,y1+6,'X');
            state:=closed;
            xD:=Z;
            setfillstyle(1,7);
            bar(55+MAL*(xBar-1)+dal-2,maxy-22-2,55+MAL*xBar-dal+2,maxy-5+2);
            if indirect_close = 0 then DisposeWindow(PWin,nr)
                                  else DisposeWindow(PWin,indirect_close);
            if LA<>1 then UpDateMainBar(PWin);
            newmin:=60+1;
            SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
            bar(x1-1,y1-1,x2,y2+1);
            mouse.showMouseCursor;
            indirect_close:=0; refresh:=false;
          end
         else
          begin
           if on_Sound then begin vawe(1200,5);end;
           mouse.hideMouseCursor;
           setfillstyle(1,7);
           bar(x2-13,y1+5+1,x2-4,y1+14+1);
           Rectangle3d(x2-13,y1+5+1,x2-4,y1+14+1,White,DarkGray);
           SetColor(0);
           settextstyle(11,0,1);
           outtextxy(x2-12,y1+6,'X');
           mouse.showMouseCursor;
          end;
    end else begin
              refresh:=false;
              ActiveWnd:=nr;
             end;
{end of close wnd section}

{begin of drag-and-drop section}
if         mouse_on(x1+3 ,y1+3,  x2-3 ,y1+18)
   and(not(mouse_on(x2-13,y1+5+1,x2-4 ,y1+14+1)))
   and(not(mouse_on(x2-25,y1+5+1,x2-16,y1+14+1)))
   and(not(mouse_on(x2-37,y1+5+1,x2-28,y1+14+1))) and (LeftButton)
  then
begin
if ActiveWnd = nr then
begin
if state<>maximized then
    begin
      if ActiveWnd <> nr then refresh:=false;
      if on_Sound then begin vawe(100,5);end;
      SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
      setColor(15);
      xi:=mouse.wherex;yi:=mouse.wherey;
      dx:=x2-x1;dy:=y2-y1;
      xd:=xi-x1;yd:=yi-y1;
{!!!} mouse.window((desktop_pos.x1+1+xd),(desktop_pos.y1+1+yd),(desktop_pos.x2-dx+xd-2),(desktop_pos.y2-dy+yd-29));
      mouse.hideMouseCursor;
      setcolor(15); with WindowPos do Rectangle(x1,y1,x2,y2);
      NewImage(x1,y1,x2,y1,p1,s1);
      NewImage(x1,y1,x1,y2,p2,s2);
      setcolor(7); with WindowPos do Rectangle(x1,y1,x2,y2);
      mouse.showMouseCursor;
      x0:=mouse.wherex;y0:=mouse.wherey;
      Rectangle3d(x1,y1,x2,y2,White,DarkGray);
      repeat
       if (xf<>mouse.wherex)or(yf<>mouse.wherey) then
        begin
         xf:=mouse.wherex;yf:=mouse.wherey;
         mouse.hideMouseCursor;
         putimage(x1,y1,p1^,XorPut);
         putimage(x1,y1,p2^,XorPut);
         putimage(x1,y2,p1^,XorPut);
         putimage(x2,y1,p2^,XorPut);
         x1:=xf-xd;
         y1:=yf-yd;
         x2:=dx+xf-xd;
         y2:=dy+yf-yd;
         putimage(x1,y1,p1^,XorPut);
         putimage(x1,y1,p2^,XorPut);
         putimage(x1,y2,p1^,XorPut);
         putimage(x2,y1,p2^,XorPut);
         with WindowPos do Rectangle3d(x1,y1,x2,y2,White,DarkGray);
         mouse.showMouseCursor;
        end
        else begin
               HandleClock;
           end;
         HandleClock;
      until (not LeftButton);
      mouse.hideMouseCursor;
      if on_Sound then begin vawe(200,5);end;
      mouse.window(0,0,maxx,maxy);

if (x0<>mouse.wherex)or(y0<>mouse.wherey) then
begin
 SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);

with WindowPos do
     bar(x1-1,y1-1,x2+1,y2+1);

 with WindowPos do
       begin
         x1:=xf-xd;
         y1:=yf-yd;
         x2:=dx+xf-xd;
         y2:=dy+yf-yd;
       end;

 refresh:=false;
end;
    mouse.showMouseCursor;
    DisposeImage(p1,s1);DisposeImage(p2,s2);
    end;

 end  else begin
           ActiveWnd:=Nr;Refresh:=false;
          end;
end;
   {end of drag-and-drop section}

   {begin of resize wnd section}
 {resize y1}
 if state<>maximized then
begin
 if (mouse.wherex>=x1)and((mouse.wherey=y1)or(mouse.wherey=y1-1))and(mouse.wherex<=x2)and(LeftButton)then
  if ActiveWnd=nr then
   begin
      if on_Sound then begin vawe(200,5);end;
      yf:=y1;
        mouse.hideMouseCursor;
        setRectangularCrossCursor;
        NewImage(x1,y1,x2,y1,p1,s1);    {sus-jos}
        NewImage(x1,y1,x1,y2,p2,s2);    {laterale}
        PutImage(x1,y2,p1^,XorPut);
        mouse.showMouseCursor;
      x0:=mouse.wherex;y0:=mouse.wherey;
      repeat
       if (yf<>mouse.wherey)and(mouse.wherey>=desktop_pos.y1+1)and(mouse.wherey<=y2-19-24) then
        begin
         mouse.hideMouseCursor;
         yf:=mouse.wherey;
         DisposeImage(p2,s2);
         NewImage(x1,yf,x1,y2,p2,s2);
         mouse.showMouseCursor;
         end
        else
         begin
         mouse.hideMouseCursor;
         PutImage(x1,yf,p1^,XorPut);
         PutImage(x1,yf,p2^,XorPut);
         PutImage(x2,yf,p2^,XorPut);
         mouse.showMouseCursor;
         if (LeftButton) then
                    repeat
                       HandleClock;
                       yi:=mouse.wherey;
                    until (yi<>yf)or(Not leftbutton);
         mouse.hideMouseCursor;
         PutImage(x1,yf,p1^,XorPut);
         PutImage(x1,yf,p2^,XorPut);
         PutImage(x2,yf,p2^,XorPut);
         mouse.showMouseCursor;
         end;
         HandleClock;
      until (not LeftButton);
      WindowPos.y1:=yf;
      DisposeImage(p1,s1);DisposeImage(p2,s2);
      mouse.hideMouseCursor;
if (x0<>mouse.wherex)or(y0<>mouse.wherey) then
    begin
      SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
      bar(x1-1,y1-1,x2+1,y2+1);
      refresh:=false;
      ActiveWnd:=nr;
    end;
      setArrowCursor;
      mouse.showMouseCursor;
     if on_Sound then begin vawe(200,5);end;
   end else begin
             refresh:=false;ActiveWnd:=nr;
            end;
  {resize y2}
 if (mouse.wherex>=x1)and(mouse.wherex<=x2)and((mouse.wherey=y2)or(mouse.wherey=y2+1))and(LeftButton) then
 if ActiveWnd = nr then
   begin
      mouse.hideMouseCursor;
      setRectangularCrossCursor;
      if on_Sound then begin vawe(200,5);end;
      yf:=y2;
        NewImage(x1,y1,x2,y1,p1,s1);    {sus-jos}
        NewImage(x1,y1,x1,y2,p2,s2);    {laterale}
        PutImage(x1,y1,p1^,XorPut);
        mouse.showMouseCursor;
      x0:=mouse.wherex;y0:=mouse.wherey;
      repeat
       if (yf<>mouse.wherey)and(mouse.wherey<=desktop_pos.y2-1-26)and(mouse.wherey>=y1+19+24) then
        begin
         mouse.hideMouseCursor;
         yf:=mouse.wherey;
         DisposeImage(p2,s2);
         NewImage(x1,y1,x1,yf,p2,s2);
         mouse.showMouseCursor;
         end
        else
         begin
         mouse.hideMouseCursor;
         PutImage(x1,yf,p1^,XorPut);
         PutImage(x1,y1,p2^,XorPut);
         PutImage(x2,y1,p2^,XorPut);
         mouse.showMouseCursor;
         if (LeftButton) then
                    repeat
                       HandleClock;
                       yi:=mouse.wherey;
                    until (yi<>yf)or(Not leftbutton);
         mouse.hideMouseCursor;
         PutImage(x1,yf,p1^,XorPut);
         PutImage(x1,y1,p2^,XorPut);
         PutImage(x2,y1,p2^,XorPut);
         mouse.showMouseCursor;
         end;
         HandleClock;
      until (not LeftButton);
      WindowPos.y2:=yf;
      DisposeImage(p1,s1);DisposeImage(p2,s2);
        mouse.hideMouseCursor;
      if (x0<>mouse.wherex)or(y0<>mouse.wherey) then
       begin
        SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
        bar(x1-1,y1-1,x2+1,y2+1);
        refresh:=false;
        ActiveWnd:=nr;
       end;
      setArrowCursor;
      mouse.showMouseCursor;
      if on_Sound then begin vawe(200,5);end;
   end  else begin
             refresh:=false;ActiveWnd:=nr;
            end;

  {resize x1}
 if ((mouse.wherex=x1)or(mouse.wherex=x1-1))and(mouse.wherey>=y1)and(mouse.wherey<=y2)and(LeftButton) then
 if ActiveWnd = nr then
   begin
      mouse.hideMouseCursor;
      setRectangularCrossCursor;
      if on_Sound then begin vawe(200,5);end;
      xf:=x1;
        NewImage(x1,y1,x2,y1,p1,s1);    {sus-jos}
        NewImage(x1,y1,x1,y2,p2,s2);    {laterale}
        PutImage(x2,y1,p2^,XorPut);
        mouse.showMouseCursor;
        x0:=mouse.wherex;y0:=mouse.wherey;
        SetTextStyle(0,0,1);
        dx:=(-TextWidth('M')*length(Name^)+x2-3*16-6-2);
        if wnd^.Menu<>nil then
                       begin
                           mnu:=menu^.items;
                           dy:=0;
                           while (mnu<>nil)and(mnu^.Name<>nil) do
                            begin
                              inc(dy,length(mnu^.name^));
                              mnu:=mnu^.next;
                            end;
                            mnu:=nil;
                           dx:= min_word(dx,x2-(dy+2)*TextWidth('M'));
                         end;

      repeat
       if (xf<>mouse.wherex)and(mouse.wherex>=desktop_pos.x1+1)and
          (mouse.wherex<=dx) then
        begin
         mouse.hideMouseCursor;
         xf:=mouse.wherex;
         DisposeImage(p1,s1);
         NewImage(xf,y1,x2,y1,p1,s1);
         mouse.showMouseCursor;
         end
        else
         begin
         mouse.hideMouseCursor;
         PutImage(xf,y1,p1^,XorPut);
         PutImage(xf,y2,p1^,XorPut);
         PutImage(xf,y1,p2^,XorPut);
         mouse.showMouseCursor;
         if (LeftButton) then
                    repeat
                       HandleClock;
                       xi:=mouse.wherex;
                    until (xi<>xf)or(Not leftbutton);
         mouse.hideMouseCursor;
         PutImage(xf,y1,p1^,XorPut);
         PutImage(xf,y2,p1^,XorPut);
         PutImage(xf,y1,p2^,XorPut);
         mouse.showMouseCursor;
         end;
         HandleClock;
      until (not LeftButton);
      WindowPos.x1:=xf;
      DisposeImage(p1,s1);DisposeImage(p2,s2);
      mouse.hideMouseCursor;
     if (x0<>mouse.wherex)or(y0<>mouse.wherey) then
     begin
      SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
      bar(x1-1,y1-1,x2+1,y2+1);
      refresh:=false;
      ActiveWnd:=nr;
     end;
      setArrowCursor;
      mouse.showMouseCursor;
      if on_Sound then begin vawe(200,5);end;
   end  else begin
             refresh:=false;ActiveWnd:=nr;
            end;

  {resize x2}
 if ((mouse.wherex=x2)or(mouse.wherex=x2+1))and(mouse.wherey>=y1)and(mouse.wherey<=y2)and(LeftButton) then
  if ActiveWnd = nr then
   begin
      mouse.hideMouseCursor;
      setRectangularCrossCursor;
      if on_Sound then begin vawe(200,5);end;
        NewImage(x1,y1,x2,y1,p1,s1);    {sus-jos}
        NewImage(x1,y1,x1,y2,p2,s2);    {laterale}
        PutImage(x1,y1,p2^,XorPut);
        mouse.showMouseCursor;
        x0:=mouse.wherex;y0:=mouse.wherey;
        SetTextStyle(0,0,1);
        dx:=(length(Name^)*TextWidth('M')+x1+3*16+6+2);
        if wnd^.Menu<>nil then
                       begin
                           mnu:=menu^.items;
                           dy:=0;
                           while (mnu<>nil)and(mnu^.Name<>nil) do
                            begin
                              inc(dy,length(mnu^.name^));
                              mnu:=mnu^.next;
                            end;
                            mnu:=nil;
                           dx:= max_word(dx,x1+(dy+2)*TextWidth('M'));
                         end;
      xf:=x2;
      repeat
       if (xf<>mouse.wherex)and(mouse.wherex<=desktop_pos.x2-1)and
       (mouse.wherex>=dx) then
        begin
         mouse.hideMouseCursor;
         xf:=mouse.wherex;
         DisposeImage(p1,s1);
         NewImage(x1,y1,xf,y1,p1,s1);
         mouse.showMouseCursor;
         end
        else
         begin
         mouse.hideMouseCursor;
         PutImage(x1,y1,p1^,XorPut);
         PutImage(x1,y2,p1^,XorPut);
         PutImage(xf,y1,p2^,XorPut);
         mouse.showMouseCursor;
         if (LeftButton) then
                    repeat
                       HandleClock;
                       xi:=mouse.wherex;
                    until (xi<>xf)or(Not leftbutton);
         mouse.hideMouseCursor;
         PutImage(x1,y1,p1^,XorPut);
         PutImage(x1,y2,p1^,XorPut);
         PutImage(xf,y1,p2^,XorPut);
         mouse.showMouseCursor;
         end;   HandleClock;
      until (not LeftButton);
      DisposeImage(p1,s1);DisposeImage(p2,s2);
      WindowPos.x2:=xf;
      mouse.hideMouseCursor;
      if (x0<>mouse.wherex)or(y0<>mouse.wherey) then
      begin
       SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
       bar(x1-1,y1-1,x2+1,y2+1);
       refresh:=false;
       ActiveWnd:=nr;
      end;
      setArrowCursor;
      mouse.showMouseCursor;
      if on_Sound then begin vawe(200,5);end;
   end   else begin
             refresh:=false;ActiveWnd:=nr;
            end;

end;
 {maximize}

if GetWindowFlag(wnd,maximizeFlag)and mouse_on(x2-25,y1+5+1,x2-16,y1+14+1)and(LeftButton)and((state=normal)
   or(state=maximized))
  then
  if ActiveWnd = nr then
    begin
     mouse.hideMouseCursor;
     setfillstyle(1,7);
     bar(x2-25,y1+5+1,x2-16,y1+14+1);
     Rectangle3d(x2-25,y1+5+1,x2-16,y1+14+1,DarkGray,White);
     SetColor(0);
     settextstyle(11,0,1);
     outtextxy(x2-23,y1+6+1,'þ');
     mouse.showMouseCursor;
     if on_Sound then begin vawe(1200,5);end;
     repeat
      HandleClock;
     until (not LeftButton);
       if mouse_on(x2-25,y1+5+1,x2-16,y1+14+1)
         then
          begin
            refresh:=false;ActiveWnd:=nr;
            if on_Sound then begin vawe(1900,5);end;
            if state=normal
          then
              begin
               mouse.hideMouseCursor;
                x1:=Desktop_pos.x1+1;
                y1:=Desktop_pos.y1+1;
                x2:=Desktop_pos.x2-1;
                y2:=Desktop_pos.y2-30;
                state:=maximized;
               mouse.showMouseCursor;
              end
            else
              begin
               mouse.hideMouseCursor;
                SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
                bar(Desktop_pos.x1-1,Desktop_pos.y1-1,Desktop_pos.x2+1,Desktop_pos.y2-30);
                state:=normal;
               mouse.showMouseCursor;
              end;
          end
         else
          begin
           if on_Sound then begin vawe(1200,5);end;
           mouse.hideMouseCursor;
           setfillstyle(1,7);
           bar(x2-25,y1+5+1,x2-16,y1+14+1);
           Rectangle3d(x2-25,y1+5+1,x2-16,y1+14+1,White,DarkGray);
           SetColor(0);
           settextstyle(11,0,1);
           outtextxy(x2-24,y1+5+1,'þ');
           mouse.showMouseCursor;
          end;
    end  else begin
             refresh:=false;ActiveWnd:=nr;
            end;

{for minimize}
 if (GetWindowFlag(wnd,minimizeFlag))and mouse_on(x2-37,y1+5+1,x2-28,y1+14+1)and(LeftButton)
  and((state=normal)or(state=maximized))
  then
  if ActiveWnd = nr then
    begin
     mouse.hideMouseCursor;
     setfillstyle(1,7);
     bar(x2-25-12,y1+5+1,x2-28,y1+14+1);
     Rectangle3d(x2-37,y1+5+1,x2-28,y1+14+1,DarkGray,White);
     SetColor(0);
     settextstyle(11,0,1);
     outtextxy(x2-36,y1+6+1,'_');
     mouse.showMouseCursor;
     if on_Sound then begin vawe(1200,5);end;
     repeat
      HandleClock;
     until (not LeftButton);
       if (mouse.wherex>=x2-25-12)and(mouse.wherex<=x2-28)and(mouse.wherey>=y1+5+1)and(mouse.wherey<=y1+14+1)
         then
       if LA<>$22 then
          begin
            refresh:=false;ActiveWnd:=nr;
            if on_Sound then begin vawe(1900,5);end;
                          if state=maximized then max:=true else max:=false;
            state:=minimized;
            mouse.hideMouseCursor;
             SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
             bar(x1-1,y1-1,x2+1,y2+1);
             DrawAppOnBar(xBar,Name^,false);
            mouse.showMouseCursor;
          end
        else  begin
              mouse.hideMouseCursor;
               DebugBar(ErrorMsg(2));
               if on_Sound then begin vawe(1200,5);end;
               setfillstyle(1,7);
               bar(x2-25-12,y1+5+1,x2-28,y1+14+1);
               Rectangle3d(x2-25-12,y1+5+1,x2-28,y1+14+1,White,DarkGray);
               SetColor(0);
               settextstyle(11,0,1);
               outtextxy(x2-37,y1+5+1,'_');
              mouse.showMouseCursor;
              end
         else
          begin
           if on_Sound then begin vawe(1200,5);end;
           setfillstyle(1,7);
           bar(x2-25-12,y1+5+1,x2-28,y1+14+1);
           Rectangle3d(x2-25-12,y1+5+1,x2-28,y1+14+1,White,DarkGray);
           SetColor(0);
           settextstyle(11,0,1);
           outtextxy(x2-37,y1+5+1,'_');
          end;
    end   else begin
             refresh:=false;ActiveWnd:=nr;
            end;
{minimize end}
{- ==== - [menu] - ==== -}
if (MenuExist(nr)) then
    begin
        dx:=0;
        mnu:=menu^.items;
    while (Mnu<>nil) do
      begin
       SetTextStyle(0,0,1);
       xi:=x1+7+dx-2; xf:=x1+7+TextWidth(mnu^.name^)+dx-2;
       yi:=y1+22-2;   yf:=y1+22+TextHeight('M')+2;

       if mouse_on(xi,yi,xf,yf)and(refresh)
           then begin
                 if (ActiveWnd<>nr)and(LeftButton) then
                  begin
                   ActiveWnd:=nr;
                   refresh:=false;
                  end;
               if (LeftButton)and(refresh)
                                 then begin
                                       mouse.hideMouseCursor;
                                       setfillstyle(1,1);
                                       bar(xi,yi,xf,yf);
                                       setcolor(15);
                                       s:=Mnu^.Name^;
                                       DrawMenuName(s,xi+2,yi+2);
                                       mouse.showMouseCursor;

                                       if mnu^.SubMenu<>nil then
                                         begin
                                           pmi:=mnu^.submenu^.items;
                                           mouse.hideMouseCursor;
                                           x0:=GetMenuItemMaxLengthX(pmi);
                                           y0:=GetMenuItemMaxLengthY(pmi);
                                           dy:=yf-yi+4;

                                           bx:=false;
                                           by:=false;

                                           if x0+xi+4>=MaxX then  begin
                                                                     xi:=maxx-x0-3;
                                                                     bx:=true;
                                                                  end;

                                           if y0+yf+12>maxy then  begin
                                                                     yf:=Maxy-y0-12-4;
                                                                     yi:=yf-dy+4;
                                                                     by:=true;
                                                                  end;

                                           PutMenuBox(pmi,xi+4,yf+8,xi+x0,MBback,s1);
                                           while pmi<>nil do
                                            begin
                                              wr_MenuItem(pmi,xi+4,yi+dy+4,xi+x0,false);
                                              inc(dy,TextHeight('M')+4);
                                              pmi:=Pmi^.next;
                                            end;
                                           mouse.showMouseCursor;
                                           repeat
                                            HandleClock;
                                           until (not mouse_on(xi+2,yi+2,xi+2+TextWidth(s),yi+2+TextHeight('M')));
                                           {the selection}

                                           repeat

                                           pmi:=mnu^.submenu^.items;
                                           sem:=false;
                                           dy:=TextHeight('M')+8;

                                            while (pmi<>nil)and(sem=false) do
                                                 begin
                                                   if mouse_on(xi+4,yi+dy+4,xi+x0,yi+TextHeight('M')+dy+2)and(pmi^.name<>nil)
                                                     and(not leftbutton)
                                                    then
                                                    begin
                                                     wr_MenuItem(pmi,xi+4,yi+dy+4,xi+x0,true);
                                                      repeat
                                                       if leftbutton then begin
                                                                          sem:=true;  {meniul a fost ales}
                                                                          SelectedMenuCommand:=pmi^.command;
                                                                           repeat
                                                                            HandleClock;
                                                                           until (not leftbutton);
                                                                          end;
                                                       TaskSwitch;
                                                      until (not mouse_on(xi+4,yi+dy+4,xi+x0,yi+dy+TextHeight('M')+2)or(sem));
                                                     wr_MenuItem(pmi,xi+4,yi+dy+4,xi+x0,false);
                                                    end;
                                                   pmi:=pmi^.next;
                                                   inc(dy,TextHeight('M')+4);
                                                 TaskSwitch;
                                                 end;
                                           TaskSwitch;
                                           until (not mouse_on(xi,yi+TextHeight('M')+2,xi+x0,yi+y0+yf-yi+8))or(sem);

                                           mouse.hideMouseCursor;
                                           PutImage(xi+4-3,yf+8-3,MBBack^,normalput);
                                           mouse.showMouseCursor;
                                           DisposeImage(MBBack,s1);

                                         end;
                                       pmi:=nil;
                                       mouse.hideMouseCursor;
                                                  setfillstyle(1,7);
                                                  setcolor(0);

                                         if bx then
                                                 if by then
                                                    begin
                                                     bar(x1+7+dx-2,y1+22-2,xf,y1+22+TextHeight('M')+2);
                                                     DrawMenuName(Mnu^.Name^,x1+7+dx-2,y1+22-2+2)
                                                    end
                                                                else
                                                    begin
                                                     bar(x1+7+dx-2,yi,xf,yf);
                                                     DrawMenuName(Mnu^.Name^,x1+7+dx-2,yi+2)
                                                    end
                                                 else
                                                    if by then
                                                    begin
                                                     bar(xi,y1+22-2,xf,y1+22+TextHeight('M')+2);
                                                     DrawMenuName(Mnu^.Name^,xi+2,y1+22-2+2);
                                                    end
                                                       else
                                                    begin
                                                     bar(xi,yi,xf,yf);
                                                     DrawMenuName(Mnu^.Name^,xi+2,yi+2);
                                                    end;

                                       mouse.showMouseCursor;
                                  end;
               end;
          inc(dx,TextWidth(mnu^.name^)+2);
          mnu:=mnu^.next;
      end;
      mnu:=nil;
    end;
if mouse_on(x1,y1,x2,y2)and(LeftButton)and(Refresh)
                         then begin
                                if ActiveWnd<>nr then begin
                                                       refresh:=false;
                                                       ActiveWnd:=nr;
                                                     end;
                              end;

if (Not MenuExist(nr))and(refresh)and(ActiveWnd=nr)and(mouse_on(x1,y1,x2,y2))
                                  then HandleWindowsControls(wnd);

if mouse_on(x1,y1,x2,y2)and(LeftButton)and(Refresh)   then
                               repeat
                                HandleClock;
                               until (not leftbutton)or(not refresh);

 if (ActiveWnd = nr) and (state<>closed)  then
  begin
    dx:=MaxWindowZ-Z;
    pw:=PWin;
     while (pw<>nil) do
      begin
        for dy:=1 to dx do
          SuccWnd(pw^.Z);
       pw:=pw^.next;
      end;
  end;
 end;


end;
end;
(*                        end   New Window procedure -- more advance than window proc          *)

procedure HandleWindows;
var i,k:byte;
   pw:PWindow;

begin
pw:=PWin;
if (Not Refresh) then
begin
for i:=1 to MaxWindowZ do
 begin
  pw:=GetWindow(GetWindowZ(i));

  if (pw <> nil) then
   begin
     with pw^,pw^.WindowPos do
          if state<>minimized then
           begin
                  DrawWindow(pw);  DrawWindowControls(pw);
           end;

   end;
 end;
refresh:=true;
end;

if (LeftButton)or(indirect_close<>0) then
 for i:=MaxWindowZ downto 1 do
     NewWindow(GetWindowZ(I));

end;(*HandleWindows*)

procedure DrawStartButton(apasat:boolean);
var c1,c2,c3,c4,d:shortint;
    maxx,maxy:word;
begin
maxx:=getmaxx;maxy:=getmaxy;
if apasat then begin
                c1:=8;
                c2:=15;
                c3:=0;
                c4:=7;
                d:=1;
               end
          else begin
                 c1:=15;
                 c2:=8;
                 c3:=7;
                 c4:=0;
                 d:=0;
               end;
if mouseCursorLevel <> 0 then mouse.hideMouseCursor ;
setfillstyle(1,7);
bar(5,maxy-22,52,maxy-5);           {draws the start button}
newrectangle3d(5,maxy-1-25+4,52,maxy-1-4,c1,c2,c3,c4);
put_wdIcon(6+d,maxy-2-25+6+d);                   {puts the Windows def icon}

if d=1 then begin
                 setcolor(8);
                 SetLineStyle(DottedLn, 10, NormWidth);
                 rectangle(6,maxy-22+1,51,maxy-6);
                 SetLineStyle(SolidLn, 0, NormWidth);
            end;

setcolor(0);                                    {write Start}
settextstyle(2,0,0);
SetUserCharSize(5 ,5, 5, 4);
outtextxy(16+8+d,maxy-2-25+6+d,'Sta t');
outtextxy(16+8+1+d,maxy-2-25+6+d,'Start ');
mouse.showMouseCursor;
end;(*DrawStartButton*)

procedure DrawMainBar;
var maxx,maxy:word;
begin
maxx:=getmaxx;maxy:=getmaxy;

   with Desktop_pos do
    begin
      x1:=1;
      y1:=1;
      x2:=Maxx-1;
      y2:=MaxY-1;
    end;

setfillstyle(1,7);                              {draws the main bar}
bar(0,maxy-1,maxx-1,maxy-1-25);
newrectangle3d(2,maxy-1-25,maxx-1,maxy-1,15,8,7,0);
DrawStartButton(false);
settextstyle(2,0,5);                            {change font}
rectangle3d(maxx-68,maxy-23,maxx-2,maxy-3,8,15);{HandleClock}
end;(*DrawMainBar*)

procedure DrawMainScreen;
begin
     {monitor}
     SetFillPattern(Patterns[DesktopFillPatern],DeskTop_color);
     bar(0,0,GetmaxX,GetMaxY);
     DrawMainBar;
end;(*DrawMainScreen*)

procedure StartPoint;
var maxx,maxy:word;
    p:PMenuItem;
    dy,dx:word;
    y0,x0:word;
    tst:TextSettingsType;
    MBack1:pointer;
    s:word;
    sel:boolean;

    function GetMaxMenuLengthX(pm:PMenuItem):word;
       var max:word;
           p:PMenuItem;
       begin
        p:=pm;
        max:=TextWidth(p^.Name^);
        while p <> nil do
         with p^ do
          begin
           if Name<>nil then
             if TextWidth(name^)>max then max:=TextWidth(name^);
           p:=p^.next;
          end;
       GetMaxMenuLengthX:=max+6;
       p:=nil;
       end;

       function GetMaxMenuLengthY(pm:PMenuItem):word;
       var max:word;
           p:PMenuItem;
       begin
        p:=pm;
        max:=0;
        while p<>nil do
         begin
           inc(max,TextHeight('M')+16);
           p:=p^.next;
         end;
       GetMaxMenuLengthY:=max;
       p:=nil;
       end;


       procedure wr_MenuItemIcon(mi:PMenuItem;x,y,xf,x0:word;selected:boolean);
       var c:byte;
           yf:word;
       begin
       mouse.hideMouseCursor;
       yf:=y+TextHeight('M')+16;
        if selected then
           begin
            setfillstyle(1,1);
            c:=15;
           end
         else
           begin
            setfillstyle(1,7);
            c:=0;
           end;
       bar(x,y,xf-2,yf-4);
       if mi^.name<>nil then begin
                               setcolor(c); DrawMenuName(mi^.Name^,x+x0+3,(y+(yf-y)div 2)-4);
                               Put_wdICON(x+3,y+4);
                               if mi^.submenu<>nil then
                                begin
                                   outtextxy(xf-2*TextWidth(#16)  ,y+TextHeight(#16),#16);
                                   outtextxy(xf-2*TextWidth(#16)+1,y+TextHeight(#16),#16);
                                end;
                             end
                        else begin
                               setcolor(8);
                               line(x+2,yf-((yf-y) div 2)-1,xf-2,yf-((yf-y) div 2)-1);
                               setcolor(15);
                               line(x+2,yf-((yf-y) div 2),xf-2,yf-((yf-y) div 2));
                             end;
       mouse.showMouseCursor;
       end;


     procedure PointMenuAct(Cmenu:PMenuItem;x1,y2,x1a,y1a,x2a,y2a:word);
     var x0,y0:word;
         x2,y1:word;
         MBack:pointer;
         size:word;
         dy,dx,loop,lp:word;
         p:PMenuItem;

           procedure wr_curMenu(xi,yi,xf,yf:word);
           begin
           setfillstyle(1,7);
           if p<>StartMenu^.items then begin
                                         bar(xi,yi,xf,yf);
                                         NewRectangle3D(xi,yi,xf,yf,15,8,7,0);
                                       end
                                  else begin
                                         bar(xi,yi,xf-2,yf);
                                       end;
                                       Put_wdICON(xi+3,yi+4);
           end;

     begin
      p:=CMenu;
      x0:=GetMaxMenuLengthX(p)+20;
      y0:=GetMaxMenuLengthY(p);
      x2:=x1+x0; y1:=y2-y0;
      dx:=2;
      if p<>StartMenu^.items then
      begin
      dx:=0;
      mouse.hideMouseCursor;
      NewImage(x1-2,y1-2,x2+2,y2+2,MBack,size);
      wr_curMenu(x1,y1,x2,y2);
      mouse.showMouseCursor;
      dy:=0;
      while (p<>nil) do
      begin
      with tst do
        SetTextStyle(Font,Direction,CharSize);
        inc(dy,TextHeight('M')+16);
        wr_MenuItemIcon(p,x1,y2-dy,x1+x0,20,false);
        p:=p^.next;
      end;
      end;
      dy:=0;sel:=false;
      lp:=0;
      if dx=0 then
      repeat
       HandleClock;
       inc(lp,100);
      until ((not LeftButton)and(mouse_on(x1,y1,x2,y2))and(not mouse_on(x1a,y1a,x2a,y2a)))
        or((lp>=5000)and(not mouse_on(x1,y1,x2,y2)) and (not mouse_on(x1a,y1a,x2a,y2a)));

    begin
    lp:=0;
      repeat
         p:=CMenu;
         dy:=TextHeight('M')+16;

      while (p<>nil)and(sel=false) do
       begin
        if mouse_on(x1,y2-dy,x1+x0,y2-dy+TextHeight('M')+16)
         and(p^.name<>nil)and(not leftbutton)
                  then
                      begin
                       wr_MenuItemIcon(p,x1,y2-dy,x1+x0-dx,20,true);
                            repeat
                            if (p^.submenu<>nil) then
                             begin
                              if (Not leftButton) then
                              begin
                              loop:=0;
                              while (loop<20000)and(mouse_on(x1,y2-dy,x1+x0,y2-dy+TextHeight('M')+16))
                                 and(Not LeftButton) do begin inc(loop,100);TaskSwitch;end;
                              end;
                              if (loop >= 20000)or(LeftButton) then
                        begin
                        sel:=false;
                        PointMenuAct(p^.submenu^.items,x1+x0,y2-dy+TextHeight('M')+16,x1,y2-dy,x1+x0,y2-dy+TextHeight('M')+16);
                        end;
                             end;

                               if (leftbutton)and(mouse_on(x1,y2-dy,x1+x0,y2-dy+TextHeight('M')+16))
                                  then
                                begin
                                   sel:=true;           {meniul a fost ales}
                                   SStartMenuCmd:=p^.command;
                                     repeat
                                      HandleClock;
                                     until (not leftbutton);

                                 end;
                                 TaskSwitch;
                              until (sel) or (not mouse_on(x1,y2-dy,x1+x0,y2-dy+TextHeight('M')+16));

                       wr_MenuItemIcon(p,x1,y2-dy,x1+x0-dx,20,false);
                       lp:=0;
                      end
                       else inc(lp,10);
                     p:=p^.next;
                     inc(dy,TextHeight('M')+16);
       end;
      TaskSwitch;
      until ((not mouse_on(x1,y1,x2,y2))and(LeftButton or RightButton))
              or
            (sel)
              or
            ((lp>=2000)and(not mouse_on(x1,y1,x2,y2))and(dx=0));
      end;
      if CMenu<>StartMenu^.items then
       begin
       mouse.hideMouseCursor;
       PutImage(x1-2,y1-2,MBack^,NormalPut);
       mouse.showMouseCursor;
       DisposeImage(MBack,size);
       end;
     end;

begin
maxx:=getmaxx;maxy:=getmaxy;
p:=StartMenu^.items;
SetTextStyle(0,0,1);
GetTextSettings(tst);
x0:=GetMaxMenuLengthX(p)+20+20;
y0:=GetMaxMenuLengthY(p);

if mouse_on(5,maxy-22,52,maxy-5)and(LeftButton) then
 begin
   DrawStartButton(true);
   mouse.hideMouseCursor;
   NewImage(5-2,maxy-22-y0-10-2,5+x0+2,maxy-22-10+2,MBack1,s);
      setfillstyle(1,7);
      bar(5,maxy-22-y0-10,5+x0,maxy-22-10);
      setfillstyle(1,8);
      bar(5,maxy-22-y0-10,5+20,maxy-22-10-3);
      NewRectangle3D(5,maxy-22-y0-10,5+x0,maxy-22-10,15,8,7,0);
      setcolor(7);
      settextstyle(8,VertDir,1);
      outtextxy(0,maxy-22-10-(TextWidth('Point'))-10,'Point');
      setcolor(15);
      outtextxy(0,maxy-22-10-(TextWidth('Point 2002'))-10,'2002');
   mouse.showMouseCursor;
   dy:=0;
   while (p<>nil) do
    begin
      with tst do
        SetTextStyle(Font,Direction,CharSize);
        inc(dy,TextHeight('M')+16);
        wr_MenuItemIcon(p,5+22,maxy-22-10-dy,5+x0,20,false);
        p:=p^.next;
     end;
   dy:=0;
      repeat
       HandleClock;
      until (not mouse_on(5,maxy-22,52,maxy-5));
  PointMenuAct(StartMenu^.items,5+22,maxy-22-10,0,0,0,0);
  DrawStartButton(false);
  mouse.hideMouseCursor;
  PutImage(5-2,maxy-22-y0-10-2,MBack1^,NormalPut);
  mouse.showMouseCursor;
  DisposeImage(MBack1,s);
 end;
end;(*StartPoint*)

{...initializarea unitatii...}
begin
  SelectedMenuCommand:=$00;SStartMenuCmd:=$00;SelectedRadioBox:=$00;
  quit:=false;refresh:=true;SelectedCeckBox:=$FF;
  indirect_close:=0;MaxWindowZ:=0;
{ --- Start Menu declaration --- }
StartMenu:=NewMenu(NewItem('Sh&ut Down ...',cmPShutDown,hcNoContext,
                   NewItem('Suspe&nd ...',cmPSuspend,hcNoContext,
                   NewLine(
                   NewItem('&Help',cmPHelp,hcNoContext,
                   NewItem('&Search',cmPSearch,hcNoContext,
                   NewItem('Se&ttings',cmPSettings,hcNoContext,
                   NewItem('&Documents',cmPDocuments,hcNoContext,
                NewSubMenu('&Programs',hcNoContext,NewMenu(
                   NewItem('&Point Explorer',cmPPointExp,hcNoContext,
                   NewItem('&MS-Dos Prompt',cmPMSDOS,hcNoContext,
                NewSubMenu('&Accessories',hcNoContext,NewMenu(
                   NewItem('&Paint',cmPPaint,hcNoContext,
                   NewItem('&Notepad',cmPNotepad,hcNoContext,
                   NewItem('&Calculator',cmPCalculator,hcNocontext,
                NewSubMenu('&Tools',hcNoContext,NewMenu(
                   NewItem('&Defragmenter',cmPDefrag,hcNoContext,
                   NewItem('&Scan Disk',cmPScanDisk,hcNoContext,
                nil))),
                nil))))),
           nil)))),nil)))))))));

end.

END UNIT - Graphic User Interface
