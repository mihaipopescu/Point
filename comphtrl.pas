program CompressHtrl;
const rets = #8#8#8#8#8#8#8#8#8;

 KeyStr : array[1..10] of string
             {cmdStr}           = ('WINDOW',     {-$1}
                           {-$03}  'BUTTON',     {-$2}
                           {-$05}  'INPUT',      {-$3}
                           {-$09}  'CECKBOX',    {-$4}
                           {-$11}  'RADIOBOX',   {-$5}
                           {-$21}  'COMBOBOX',   {-$6}
             {opStr}               'ID',         {-$7} {1 byte   -   1 byte }
                                   'INSERTPOINT',{-$8} {2 word   -   4 bytes}
                                   'POSITION',   {-$9} {4 word   -   8 bytes}
                                   'STRING');    {-$a} {1 string - 256 bytes}

       bp_Window   = 1 shl 0;
       bp_Button   = 1 shl 1;
       bp_Input    = 1 shl 2;
       bp_CeckBox  = 1 shl 3;
       bp_RadioBox = 1 shl 4;
       bp_ComboBox = 1 shl 5;

type   TWindowPosition = record
         x1,y1,x2,y2:word;
       end;

       TPointPosition = record
         x,y:word;
       end;

var ocb:byte;

procedure wr_help;
begin
writeln('Syntax:');
writeln('x:\..\comphtrl.exe inputfile outputfile');
writeln;
writeln('NOTE: If the inputfile is a compressed file, the outputfile will be the');
writeln('      decompressed file of the former, else is otherwise.');
end;(*wr_help*)

procedure Error(n:byte);
var ErrorStr:string;
begin
   case  n of
         0 : ErrorStr := 'Normal exit.';
         1 : ErrorStr := 'Syntax error';
         2 : ErrorStr := 'File open error';
         3 : ErrorStr := 'File creation error';
         4 : ErrorStr := 'HTRL syntax error';
   end;
write('ERROR[',n,']: ',ErrorStr);halt(n);
end;(*Error*)

procedure wr_id;
begin
writeln('         +-------------------------------------------------------------+');
writeln('         |----=== Compress/DeCompress Hyper Text Resource Files ===----|');
writeln('         +-------------------------------------------------------------+');
writeln('                        Copyright (c) by System Quick Programming Group.');
writeln('                                             Programator Mihai Popescu.');
end;(*wr_id*)


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


{languige translation functions}
procedure DelSp(var s:string);
var s1:string;
    i:byte;
    o:boolean;
begin
s1:='';o:=true;
for i:=1 to length(s) do
 begin
  if s[i]='"' then o:=not o;
   if o then begin
    if (ord(s[i])>32)and(ord(s[i])<127) then s1:=s1+s[i]
             end
        else s1:=s1+s[i];
 end;
s:=s1;
end;(*DelSp*)

procedure UpperCase(var s:string);
var i:byte;
    o:boolean;
begin
o:=true;
for i:=1 to length(s) do
 begin
  if s[i]='"' then o:=not o;
  if o then s[i]:=UpCase(s[i]);
 end;
end;(*UpperCase*)

function getbyte(s:string;var id:byte):boolean;
var s1:string;
    b:boolean;
    i:byte;
    code:integer;
begin
s1:='';b:=false;
for i:=1 to length(s) do
  case s[i] of
    '=',';' : b:=not b;
    else if (s[i] in ['0'..'9'])and(b) then s1:=s1+s[i];
  end;
val(s1,id,code);
getbyte:=(code=0)and(not b);
end;(*GetByte*)

function getwinpos(s:string;var pos:TWindowPosition):boolean;
var s1:string;
    b,err:boolean;
    i,j:byte;
    w:word;
    code:integer;
begin
s1:='';b:=false;err:=false;j:=1;
for i:=1 to length(s) do
  case s[i] of
      '='     : b:=not b;
      ',',';' : begin
                     val(s1,w,code);
                     if code<>0 then err:=true;
                   with pos do
                    case j of
                      1 : x1:=w;
                      2 : y1:=w;
                      3 : x2:=w;
                      4 : y2:=w;
                    end;
                    inc(j,1);s1:='';if s[i]=';' then b:=false;
                end
      else if (b) and (s[i] in ['0'..'9']) then s1:=s1+s[i];
  end;
getwinpos:=(not err)and(not b);
end;(*GetWinPos*)

function getpointpos(s:string;var ins:TPointPosition):boolean;
var s1:string;
    b,err:boolean;
    i,j:byte;
    w:word;
    code:integer;
begin
s1:='';b:=false;err:=false;j:=1;
for i:=1 to length(s) do
  case s[i] of
      '='     : b:=not b;
      ',',';' : begin
                     val(s1,w,code);
                     if code<>0 then err:=true;
                   with ins do
                    case j of
                      1 : x:=w;
                      2 : y:=w;
                    end;
                    inc(j,1);s1:='';if s[i]=';' then b:=false;
                end
      else if (b) and (s[i] in ['0'..'9']) then s1:=s1+s[i];
  end;
getpointpos:=(not err)and(not b);
end;(*GetPointPos*)

function getstring(s:string;var str:string):boolean;
var i:byte;
    b:boolean;
begin
str:='';b:=false;
 for i:=1 to length(s) do
  case s[i] of
      '"' : b:=not b
    else if (b) then str:=str+s[i];
  end;
getstring:=not b;
end;(*getstring*)
{languige translation}

function GetFileSize(filename:string):longint;
var f:file;
begin
   assign(f,filename);
   {$I-} reset(f,1); {$I+}
   if IOResult <> 0 then Error(2);
   GetFileSize:=FileSize(f);
end;(*GetFIleSize*)

procedure Compress(inputfilename,outputfilename:string);
var fi:text;
    fo:file;
    s,ss:string; ch:char;
    i,o:byte;
    ppos:TPointPosition;
    wpos:TWindowPosition;
    is,fs:longint;

      procedure wr_bwr(i:byte);
      begin
       inc(fs,i);
       write(fs:3,' bytes',rets);
      end;

begin
  assign(fi,inputfilename);
  {$I-} reset(fi); {$I+}
  if IOResult <> 0 then Error(2);
  is:=GetFileSize(inputfilename);
  Writeln('Reading  ... ',is,' bytes');
  assign(fo,outputfilename);
  {$I-} rewrite(fo,1); {$I+}
  If IoResult <> 0 then Error(3);
  Write('Writting ... ');
  ocb:=0;fs:=0;
  while (not eof(fi)) do
  begin
  readln(fi,s);
   if s[2]<>'!' then
    begin
       DelSp(s);UpperCase(s);
       for i:=1 to 6 do
        if Pos(KeyStr[i],s)<>0 then
        if (s[1]='<')and(s[length(s)]='>') then
        if s[2]<>'/' then ocb:=setbit(ocb,i-1,1)
                     else ocb:=setbit(ocb,i-1,0);

       if getbit(ocb,0)=1 then
         for i:=7 to 10 do
          if (Pos(KeyStr[i],s)<>0) then
            begin
                  ch:=chr(((i-7) shl 6) or ocb);
                  BlockWrite(fo,ch,1);wr_bwr(1);
                  case i of
                    $7 : begin
                               if getbyte(s,o) then ch:=chr(o)
                                               else Error(4);
                               blockwrite(fo,ch,1);wr_bwr(1);
                         end;
                    $8 : begin
                               if getpointpos(s,ppos) then begin
                                                            with ppos do
                                                             begin
                                                             ch:=chr(ord(Hi(x)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(x)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             ch:=chr(ord(Hi(y)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(y)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             end;
                                                           end
                                                      else Error(4);
                         end;
                    $9 : begin
                               if getwinpos(s,wpos) then begin
                                                            with wpos do
                                                             begin
                                                             ch:=chr(ord(Hi(x1)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(x1)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             ch:=chr(ord(Hi(y1)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(y1)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             ch:=chr(ord(Hi(x2)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(x2)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             ch:=chr(ord(Hi(y2)));
                                                             blockwrite(fo,ch,1);
                                                             ch:=chr(ord(Lo(y2)));
                                                             blockwrite(fo,ch,1);
                                                             wr_bwr(2);
                                                             end;
                                                           end
                                                      else Error(4);
                         end;
                    $A : begin
                            if getstring(s,ss) then begin
                                                      blockwrite(fo,ss,length(ss)+1);wr_bwr(Length(ss)+1);
                                                    end
                                               else Error(4);
                         end;
                  end;
            end;
        end;
  end;
close(fi);close(fo);writeln;
Writeln('Compression: ',((is-fs)/is*100):3:2,' %');
end;(*Compress*)

procedure DeCompress(inputfilename,outputfilename:string);
var fi:file;
    fo:text;
    ch:char;
    i,o:byte;
    w:word;
    is,fs:longint;

      procedure wr_bwr(i:byte);
      begin
      inc(fs,i);
      write(fs:3,' lines',rets);
      end;

begin
  assign(fi,inputfilename);
  {$I-} reset(fi,1); {$I+}
  if IOResult <> 0 then Error(2);
  is:=GetFileSize(inputfilename);
  Writeln('Reading    ... ',is,' bytes');
  assign(fo,outputfilename);
  {$I-} rewrite(fo); {$I+}
  If IoResult <> 0 then Error(3);
  Write('Writting   ... ');
  ocb:=0;fs:=0;
  while (not eof(fi)) do
  begin
       BlockRead(fi,ch,1);
       o:=ord(ch);
       for i:=1 to 6 do
         if (GetBit(ocb,i-1)=1)and(GetBit(o,i-1)=0) then begin
                                                            ocb:=setbit(ocb,i-1,0);
                                                            Writeln(fo,'</'+KeyStr[i]+'>');
                                                            wr_bwr(1);
                                                         end;
       for i:=1 to 6 do
         if (GetBit(ocb,i-1)=0)and(GetBit(o,i-1)=1) then begin
                                                            ocb:=setbit(ocb,i-1,1);
                                                            Writeln(fo,'<'+KeyStr[i]+'>');
                                                            wr_bwr(1);
                                                         end;

       o:=(o shr 6);
       case o of
            0 : begin
                      BlockRead(fi,ch,1);
                      Writeln(fo,KeyStr[$7],'=',ord(ch),';');
                      wr_bwr(1);
                end;
            1 : begin
                      write(fo,KeyStr[$8],'=');wr_bwr(1);
                      w:=0;
                      for i:=1 to 4 do
                       begin
                         BlockRead(fi,ch,1);
                         case i of
                             1,3 : w:=ord(ch) shl 8;
                             2,4 : begin
                                    w:=w or ord(ch);
                                    write(fo,w);
                                    if i=2 then write  (fo,',')
                                           else writeln(fo,';');wr_bwr(1);
                                    w:=0;
                                   end;
                         end;
                       end;
                end;
            2 : begin
                      write(fo,KeyStr[$9],'=');
                      w:=0;
                      for i:=1 to 8 do
                       begin
                         BlockRead(fi,ch,1);
                         case i of
                          1,3,5,7 : w:=ord(ch) shl 8;
                          2,4,6,8 : begin
                                     w:=w or ord(ch);
                                     write(fo,w);
                                     if i<>8 then write  (fo,',')
                                             else writeln(fo,';');wr_bwr(1);
                                     w:=0;
                                   end;
                         end;
                       end;

                end;
            3 : begin
                      write(fo,KeyStr[$A],'="');
                      BlockRead(fi,ch,1);
                      for i:=1 to ord(ch) do
                       begin
                        BlockRead(fi,ch,1);
                        write(fo,ch);
                       end;
                      writeln(fo,'";');wr_bwr(1);
                end;
       end;
  end;
for i:=6 downto 1 do
      if GetBit(ocb,i-1)=1 then writeln(fo,'</',KeyStr[i],'>');wr_bwr(1);
close(fi);close(fo);
writeln;fs:=GetFileSize(outputfilename);
Writeln('DeCompression: ',(abs(is-fs)/is*100):3:2,' %');
end;(*DeCompress*)

function IsCompressed(filename:string):boolean;
var f:file of char;
    ch:char;
begin
assign(f,filename);{$I-} reset(f); {$I+}
If IOResult <> 0 then Error(2);
read(f,ch);
IsCompressed:=(ch=chr(1));
end;(*IsCompressed*)


{Main program}
begin
wr_id;
if ParamCount <> 2 then  begin wr_help;Error(1); end;
if IsCompressed(ParamStr(1)) then DeCompress(ParamStr(1),ParamStr(2))
                             else   Compress(ParamStr(1),ParamStr(2))
end.