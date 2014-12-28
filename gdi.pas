unit GDI;
                        {The Graphis Driver Interface [0xf]}

Interface

uses crt,dos,graph,xmsarray;


     {graph}
     procedure init_graph;
     procedure destroy_graph;
     procedure RectAngle3d(x1,y1,x2,y2,color1,color2:word);
     procedure NewRectangle3d(x1,y1,x2,y2,color1,color2,color3,color4:word);

     {images}
     procedure PutXMSImage(img:PXMS2DArray;x1,y1,x2,y2:word);
     function GetXMSImage(x1,y1,x2,y2:word):PXMS2DArray;

     procedure NewImage(x1,y1,x2,y2:integer;var p:pointer;var size:word);
     procedure DisposeImage(p:pointer;size:word);
     procedure Load_IconWin16(xx,yy :integer;iconname :string);
     procedure Load_IconWin32(xx,yy :integer;iconname :string;transparent:byte);
     procedure load_icon32(xx,yy :integer;iconname :string);
     procedure Put_wdICON(IcoX,IcoY:INTEGER);

     {colors}
     procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
     procedure SetPal(ColorNo : Byte; R,G,B : Byte);
     procedure RESET_COLORS;
     procedure SWAP_COLORS(col1,col2 :byte);
     procedure Fade_Down(speed :byte);

     {BitWise functions}
     function  setbit(nr:byte;bit,on:byte):byte;
     function  getbit(nr,bit:byte):byte;
     function  getbitNo(nr:byte):byte;
     function  getbyteNo(nr:byte):byte;

     {other}
     function  FileExists(FileName: String): Boolean;
     procedure CopyFile(FromFName, ToFName:String);
     function  ErrorMsg(id:byte):string;
     procedure SCREEN_OFF;
     procedure SCREEN_ON;
     procedure DebugBar(s:string);
     function  Int2Str(x:longint):string;
     procedure Vawe(Hz,pas:word);


Implementation

var regs:registers;

function ErrorMsg(id:byte):string;
begin
        case id of

             1:ErrorMsg:='ERROR[01]: Graphic Driver Module crashed ! The program is halted.';
             2:ErrorMsg:='ERROR[02]: Too many windows opend. Task full.';
             3:ErrorMsg:='ERROR[03]: Resource File not found. Window loading aborded.';
             4:ErrorMsg:='ERROR[04]: Not enough memory !';
             5:ErrorMsg:='ERROR[05]: Error opening a file. Perhaps it doesnt exists.';
             6:ErrorMsg:='ERROR[06]: Error creating new file.';

        else
              ErrorMsg :='General error';
        end;
end;(*ErrorMsg*)

function FileExists(FileName: String): Boolean;
var
  F: file;
begin
  {$I-}
  Assign(F, FileName);
  FileMode := 0;
  Reset(F);
  Close(F);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;(*FileExists*)

procedure loadChar;
Type
  ByteArray  = Array[0..15] of Byte;
  CharArray  = Array[1..29] of Record
    CharNum  : Byte;
    CharData : ByteArray;
  end;
Const newChars : CharArray =
      ((CharNum : 218;CharData :
      (0,0,7,15,28,56,48,48,48,48,48,48,48,48,48,48)),           {⁄}
      (CharNum : 194;CharData:
      (0,0,255,255,0,0,0,0,0,0,0,0,0,0,0,0)),                    {¬}
      (CharNum : 191;CharData:
      (0,0,224,240,56,28,12,12,12,12,12,12,12,12,12,12)),        {ø}
      (CharNum : 195;CharData:
      (48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48)),        {√}
      (CharNum : 180;CharData:
      (12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12)),        {¥}
      (CharNum : 192;CharData:
      (48,48,48,48,48,48,48,48,48,48,56,28,15,7,0,0)),           {¿}
      (CharNum : 193;CharData:
      (0,0,0,0,0,0,0,0,0,0,0,0,255,255,0,0)),                    {¡}
      (CharNum : 217;CharData:
      (12,12,12,12,12,12,12,12,12,12,28,56,240,224,0,0)),        {Ÿ}

  {J} (CharNum : 210;CharData :
      ($1E,$1E,$0C,$0C,$0C,$0C,$0C,$0C,$CC,$CC,$CC,$CC,$78,$78,$00,$00)),
  {O} (Charnum : 190;CharData :
      ($38,$38,$6C,$6C,$C6,$C6,$C6,$C6,$C6,$C6,$6C,$6C,$38,$38,$00,$00)),
  {S} (Charnum : 141;CharData :
      ($7C,$7C,$C6,$C6,$E0,$E0,$78,$78,$0E,$0E,$C6,$C6,$7C,$7C,$00,$00)),
  {D} (Charnum : 159;CharData :
      ($F8,$F8,$6C,$6C,$66,$66,$66,$66,$66,$66,$6C,$6C,$F8,$F8,$00,$00)),
  {I} (Charnum : 241;CharData :
      ($78,$78,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$78,$78,$00,$00)),
  {C} (Charnum : 226;CharData :
      ($3C,$3C,$66,$66,$C0,$C0,$C0,$C0,$C0,$C0,$66,$66,$3C,$3C,$00,$00)),
  {K} (Charnum : 171;CharData :
      ($E6,$E6,$66,$66,$6C,$6C,$78,$78,$6C,$6C,$66,$66,$E6,$E6,$00,$00)),
  {M} (Charnum : 156;CharData :
      ($C6,$C6,$EE,$EE,$FE,$FE,$FE,$FE,$D6,$D6,$C6,$C6,$C6,$C6,$00,$00)),
  {A} (Charnum : 243;CharData :
      ($30,$30,$78,$78,$CC,$CC,$CC,$CC,$FC,$FC,$CC,$CC,$CC,$CC,$00,$00)),
  {N} (Charnum : 250;CharData :
      ($C6,$C6,$E6,$E6,$F6,$F6,$DE,$DE,$CE,$CE,$C6,$C6,$C6,$C6,$00,$00)),
  {F} (CharNum : 161;CharData :
      ($FE,$FE,$62,$62,$68,$68,$78,$78,$68,$68,$60,$60,$F0,$F0,$00,$00)),
  {T} (Charnum : 254;CharData :
      ($FC,$FC,$B4,$B4,$30,$30,$30,$30,$30,$30,$30,$30,$78,$78,$00,$00)),
  {W} (Charnum : 130;CharData :
      ($C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$D6,$D6,$FE,$FE,$6C,$6C,$00,$00)),
  {R} (Charnum : 172;CharData :
      ($FC,$FC,$66,$66,$66,$66,$7C,$7C,$6C,$6C,$66,$66,$E6,$E6,$00,$00)),
  {E} (Charnum : 253;CharData :
      ($FE,$FE,$62,$62,$68,$68,$78,$78,$68,$68,$62,$62,$FE,$FE,$00,$00)),
  {c} (Charnum : 199;CharData :
      ($00,$00,$00,$00,$78,$78,$CC,$CC,$C0,$C0,$CC,$CC,$78,$78,$00,$00)),
  {(} (Charnum : 247;CharData :
      ($18,$18,$30,$30,$60,$60,$60,$60,$60,$60,$30,$30,$18,$18,$00,$00)),
  {)} (Charnum : 233;CharData :
      ($60,$60,$30,$30,$18,$18,$18,$18,$18,$18,$30,$30,$60,$60,$00,$00)),
  {1} (Charnum : 248;CharData :
      ($30,$30,$70,$70,$30,$30,$30,$30,$30,$30,$30,$30,$FC,$FC,$00,$00)),
  {9} (Charnum : 223;CharData :
      ($78,$78,$CC,$CC,$CC,$CC,$7C,$7C,$0C,$0C,$18,$18,$70,$70,$00,$00)),
  {7} (Charnum : 242;CharData :
      (254,254,198,198,12,12,24,24,48,48,48,48,48,48,0,0)));
Var
  i : Byte;
begin
  for i := 1 to 29 do With regs do begin
    ah := $11;
    al := $0;
    bh := $10;
    bl := 0;
    cx := 1;
    dx := NewChars[i].CharNum;
    es := seg(NewChars[i].CharData);
    bp := ofs(NewChars[i].CharData);
    intr($10,regs);
  end;
end;(*loadchar*)

Procedure WAIT(ms : Word); Assembler;
Asm
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  int $15;
end;(*Wait*)

PROCEDURE Put_wdICON(IcoX,IcoY:INTEGER);
CONST ICOMAP:ARRAY[0..$f,0..$f]OF BYTE=(
($0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0),
($0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$0,$0,$0,$0,$0),
($0,$0,$0,$0,$1,$d,$d,$1,$1,$a,$a,$1,$0,$0,$0,$0),
($0,$0,$0,$1,$d,$d,$d,$1,$1,$a,$a,$a,$1,$0,$0,$0),
($0,$0,$1,$d,$d,$d,$d,$1,$1,$a,$a,$a,$a,$1,$0,$0),
($0,$1,$d,$d,$d,$d,$d,$1,$1,$a,$a,$a,$a,$a,$1,$0),
($0,$1,$d,$d,$d,$d,$1,$1,$1,$1,$a,$a,$a,$a,$1,$0),
($0,$1,$1,$1,$1,$1,$1,$0,$0,$1,$1,$1,$1,$1,$1,$0),
($0,$1,$1,$1,$1,$1,$1,$0,$0,$1,$1,$1,$1,$1,$1,$0),
($0,$1,$b,$b,$b,$b,$1,$1,$1,$1,$f,$f,$f,$f,$1,$0),
($0,$1,$b,$b,$b,$b,$b,$1,$1,$f,$f,$f,$f,$f,$1,$0),
($0,$0,$1,$b,$b,$b,$b,$1,$1,$f,$f,$f,$f,$1,$0,$0),
($0,$0,$0,$1,$b,$b,$b,$1,$1,$f,$f,$f,$1,$0,$0,$0),
($0,$0,$0,$0,$1,$b,$b,$1,$1,$f,$f,$1,$0,$0,$0,$0),
($0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$0,$0,$0,$0,$0),
($0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0));
VAR IcoCnt,IcoCnt2:INTEGER;
BEGIN
  FOR IcoCnt:=0 TO $f DO
    FOR IcoCnt2:=0 TO $f DO
     IF ICOMAP[IcoCnt2,IcoCnt]<>0 THEN
       PUTPIXEL(IcoX+IcoCnt2,IcoY+IcoCnt,ICOMAP[IcoCnt2,IcoCnt]-1);
END;(*Put_wdICON*)

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


Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;(*GetPal*)

Procedure SetPal(ColorNo : Byte; R,G,B : Byte);
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;(*SetPal*)

procedure RESET_COLORS;
const
  def_colors :array[0..15,1..4] of byte =

              (( 0, 0, 0, 0),     { 0 = zwart }
               ( 1, 0, 0,42),     { 1 = blauw }
               ( 2, 0,42, 0),     { 2 = groen }
               ( 3, 0,42,42),     { 3 = turkoois }
               ( 4,42, 0, 0),     { 4 = rood }
               ( 5,42, 0,42),     { 5 = paars }
               (20,42,21, 0),     { 6 = bruin }
               ( 7,42,42,42),     { 7 = lichtgrijs }
               (56,21,21,21),     { 8 = donkergrijs }
               (57,21,21,63),     { 9 = lichtblauw }
               (58,21,63,21),     {10 = lichtgroen }
               (59,21,63,63),     {11 = lichtturkoois }
               (60,63,21,21),     {12 = lichtrood }
               (61,63,21,63),     {13 = lichtpaars }
               (62,63,63,21),     {14 = geel }
               (63,63,63,63));    {15 = wit }
var p:integer;
begin
  for p :=0 to 15 do SetPal(def_colors[p,1],def_colors[p,2],
                                def_colors[p,3],def_colors[p,4]);
end;(*RESET_COLORS*)

procedure Fade_Down(speed :byte);
VAR p,loop1,loop2:integer;
    Tmp : Array [1..3] of byte;

procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;(*WaitRetrace*)

BEGIN
  For loop1:=1 to 64 do BEGIN
    for p :=0 to speed do waitretrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
      SetPal (loop2,Tmp[1],Tmp[2],Tmp[3]);
    END;
  END;
END;(*Fade_Down*)

procedure load_icon32(xx,yy :integer;iconname :string);
var
  r,rr,q :byte;
  f      :text;
  x,y,p  :integer;
  ch     :char;
begin
  x :=xx;y :=yy;
  assign(f,iconname);
  {$I-} reset(f); {$I+}
  if ioresult =0 then begin
    for p :=1 to 766 do begin
      read(f,ch);q :=ord(ch);
      if (p > 142) and (p < 653) then
      begin
        r :=(q+37) shr 4;  q:=q-37;
        rr :=q-r div 4;
        putpixel(x,y,r);putpixel(x+1,y,rr);
        inc(x,2);
        if x =xx+32 then
        begin
          x :=xx;
          dec(y);
        end;
      end;
    end;
    close(f);
  end else DebugBar(ErrorMsg(5));
end;(*load_icon32*)

 function SwapColor(icol:byte):byte;
 begin
   case icol of
       11: SwapColor:=14;
       4 : SwapColor:=1;
       1 : SwapColor:=12;
       3 : SwapColor:=6;
       6 : SwapColor:=3;
       9 : SwapColor:=4;
       12: SwapColor:=9;
       14: SwapColor:=11;
      else SwapColor:=icol;
     end;
 end;(*SwapColor*)

procedure Load_IconWin32(xx,yy :integer;iconname :string;transparent:byte);
var
  r,rr,q :byte;
  f    :text;
  x,y,p  :integer;
  ch:char;
begin
  x :=xx;y :=yy;
  assign(f,iconname);
  {$I-} reset(f); {$I+}
  if ioresult =0 then begin
    for p :=1 to 766 do begin
      read(f,ch);q :=ord(ch);
      if (p >126) and (p <639) then begin
        r := q shr 4;
        rr:= q and $F;
        r := SwapColor(r);
        rr:= SwapColor(rr);
        if r <> transparent then
        putpixel(x,y,r);
        if rr <> transparent then
        putpixel(x+1,y,rr);
        inc(x,2);
        if x =xx+32 then begin
          x :=xx;dec(y);
        end;
      end;
    end;
    close(f);
  end else DebugBar(ErrorMsg(5));
end;(*Load_IconWin32*)

procedure Load_IconWin16(xx,yy :integer;iconname :string);
var
  r,rr,q :byte;
  f    :text;
  x,y,p  :integer;
  ch:char;
begin
  x :=xx;y :=yy;
  assign(f,iconname);
  {$I-} reset(f); {$I+}
  if ioresult =0 then begin
    for p :=1 to $435 do begin
      read(f,ch);q :=ord(ch);
      if (p >$376) and (p <$3F7) then begin
        r :=q shr 4;
        rr:=q and $F;
        r:=SwapColor(r);
        rr:=SwapColor(rr);
        putpixel(x,y,r);
        putpixel(x+1,y,rr);
        inc(x,2);
        if x =xx+16 then begin
          x :=xx;dec(y);
        end;
      end;
    end;
    close(f);
  end else DebugBar(ErrorMsg(5));
end;(*Load_IconWin16*)

procedure Vawe(Hz,pas:word);
begin
nosound;sound(Hz);delay(pas);nosound;
end;(*Vawe*)

procedure DebugBar(s:string);
var xi,yi,xf,yf:integer;
begin
   setfillstyle(1,3);
   bar(10,10,630,20);
   setcolor(14);
   settextstyle(0,0,1);
   outtextxy(10,10,s);
end;(*DebugBar*)

function Int2Str(x:longint):string;
var s:string;
begin
str(x,s);int2str:=s;
end;(*Int2Str*)

procedure SWAP_COLORS(col1,col2 :byte);
var
  r1,g1,b1,
  r2,g2,b2 :byte;
begin
  if (col1 in[0..15]) and (col2 in[0..15]) then begin
    getpal(col1,r1,g1,b1);
    getpal(col2,r2,g2,b2);
    setpal(col1,r2,g2,b2);
    setpal(col2,r1,g1,b1);
  end;
end;(*SWAP_COLORS*)

procedure SCREEN_OFF;
var
  regs :registers;
begin
  regs.ah := $12;                    { 12 = vgahi 640 x 480 }
  regs.al := ord(1);                 { 0 = on, 1 = off }
  regs.bl := $36;                    { Subfunction }
  intr($10, regs);                   { Call BIOS }
end;(*SCREEN_OFF*)

procedure SCREEN_ON;
var
  regs :registers;
begin
  regs.ah := $12;                    { 12 = vgahi 640 x 480 }
  regs.al := ord(0);                 { 0 = on, 1 = off }
  regs.bl := $36;                    { Subfunction }
  intr($10, regs);                   { Call BIOS }
end;(*SCREEN_ON*)

function hexswap(s:string):string;
var i,n,b:byte;
begin
for i:=1 to length(s) do
begin
    n:=ord(s[i]);
       asm
           mov bl,n
           mov cl,n
           shl bl,4
           shr cl,4
           or  bl,cl
           mov b,bl
       end;
   s[i]:=chr(b);
end;
hexswap:=s;
end;(*hexswap*)

function setbit(nr:byte;bit,on:byte):byte;assembler;
      asm
         mov al,nr
         mov cl,bit
         mov bl,$FE
         ror al,cl
         and al,bl
         or  al,on
         rol al,cl
      end;(*setbit*)

function getbit(nr,bit:byte):byte;assembler;
      asm
         mov al,nr
         mov cl,bit
         shr al,cl
         and al,1
      end;(*getbit*)

function getbyteNo(nr:byte):byte;assembler;
      asm
          mov al,nr
          shr al,3
          inc al
      end;(*getbyteNo*)

function getbitNo(nr:byte):byte;assembler;
      asm
          mov cl,nr
          and cl,7
          mov al,8
          sub al,cl
      end;(*getbitNo*)

function GetXMSImage(x1,y1,x2,y2:word):PXMS2DArray;
var Img:PXMS2DArray;
    i,j,w:word;
begin
  New(Img, Init(y2-y1, x2-x1, 2));
  If Img^.Handle > 0 Then
    begin
      for i:=y1 to y2 do
       for j:= x1 to x2 do
         begin
          w:=0;
          w:= GetPixel(j,i);
          Img^.SetElement(i-y1+1, j-x1+1, w);
         end;
      GetXMSImage:=Img;
    end
   else GetXMSImage:=nil;
end;(*GetXMSImage*)

procedure PutXMSImage(img:PXMS2DArray;x1,y1,x2,y2:word);
var i,j,w:word;
begin
 for i:=y1 to y2 do
  for j:=x1 to x2 do
    begin
      Img^.GetElement(i-y1+1, j-x1+1, w);
      PutPixel(j,i,byte(w));
    end;
end;(*PutXMSImage*)

procedure CopyFile(FromFName, ToFName:String);
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;
begin
  Assign(FromF, FromFName);
  Reset(FromF, 1);
  Assign(ToF, ToFName);
  Rewrite(ToF, 1);
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
end;(*CopyFile*)

procedure init_graph;
var gDriver,gMode,ErrorCode:integer;
begin
     gdriver:=detect;
     gMode:=0;
     InitGraph(gDriver,gMode,'Drivers\');
      ErrorCode:=GraphResult;
     if ErrorCode<>grOk then
      begin
       writeln;
       Write('Graphics error: ');
       Writeln(GraphErrorMsg(ErrorCode));
       Writeln(ErrorMsg(1));
       Halt(1);
      end;
     DirectVideo:=True;
     cleardevice;
     SetVisualPage(0);
     SetActivePage(0);
end;(*init_graph*)

procedure destroy_graph;
begin
     ClearDevice;
     CloseGraph;
     RestoreCrtMode;
end;(*destroy_graph*)

procedure RectAngle3d(x1,y1,x2,y2,color1,color2:word);
begin
SetColor(color1);
line(x1-1,y1-1,x2,y1-1);
line(x1-1,y1-1,x1-1,y2+1);
Setcolor(color2);
line(x1-1,y2+1,x2,y2+1);
line(x2,y2+1,x2,y1-1);
end;(*Rectangle3d*)


{  more advance by Rectangle3d but is only used for buttons to increas 3d effect.  }
procedure NewRectangle3d(x1,y1,x2,y2,color1,color2,color3,color4:word);
begin
{the interior rectangle}
SetColor(color1);
line(x1-1,y1-1,x2+1,y1-1);
line(x1-1,y1-1,x1-1,y2+1);
Setcolor(color2);
line(x1-1,y2+1,x2+1,y2+1);
line(x2+1,y2+1,x2+1,y1-1);
{the exterior rectangle}
Setcolor(color3);
line(x1-2,y1-2,x2+2,y1-2);
line(x1-2,y1-2,x1-2,y2+2);
Setcolor(color4);
line(x1-2,y2+2,x2+2,y2+2);
line(x2+2,y2+2,x2+2,y1-2);
end;(*NewRectangle3d*)


begin
  loadchar;
  clrscr;
  regs.ax :=$0100;regs.cx :=$2607;intr(16,regs);
  textcolor(13);
  gotoxy(16,11);write('⁄¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ø');
  gotoxy(16,12);write('√                                             ¥');
  gotoxy(16,13);write('¿¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡Ÿ');
  gotoxy(19,12);textcolor(12);
  writeln(HexSwap
(#53#151#55#71#86#214#2#21#87#150#54#182#2#5#39#246#118#39#22#214#214#150#230#118#2#116#39#246#87#7#2#130#54#146));
  gotoxy(56,12);textcolor(9);
  write(HexSwap(#35#3#3#35));
  wait(1000);Fade_down(0);Reset_colors;
end.