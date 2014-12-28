unit HTRL ;      {   -----------------------------------------
		     ------==== Hyper Text Resource ====------
		     --------------------------Language-------   }
interface
const
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

       WindowClass = record
         ID       : byte;
         position : TWindowPosition;
         caption  : String;
       end;

       InputClass  = record
          ID         : byte;
          InsertPoint: TPointPosition;
          TextLength : byte;
          MaxXChar   : byte;
          MaxYChar   : byte;
        end;

        ButtonClass = record
           ID         : byte;
           Position   : TWindowPosition;
           Caption    : String;
         end;

         ListClass   = record
           ID         : byte;
           InsertPoint: TPointPosition;
         end;

var ocb:byte;   {open/close boolean}

            {interface PRC ( compressed HTR files ) }
            procedure ImportWindow(_id:byte;filename:string;var winC:WindowClass);


implementation

procedure ImportWindow(_id:byte;filename:string;var winC:WindowClass);
var fi:file;
    i,o:byte;
    ch:char;
    w:word;
    s:string;
    b:boolean;
begin
assign(fi,filename);reset(fi,1);
ocb:=0;b:=false;
  while (not eof(fi)) do
  begin
       BlockRead(fi,ch,1);
       o:=ord(ch);
       ocb:=o and $3f;
       o:=o shr 6;

       case o of
            0 : begin
                      BlockRead(fi,ch,1);
                      b:=(ord(ch)=_id)and(ocb=1);
                      if b then winC.id:=ord(ch);
                end;
            1 :         {insert point not used for windows, skipping 4 bytes ... }
                        Seek(fi,FilePos(fi)+4);

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
                                     with winC.position do
                                     case i of
                                          2 : x1:=w;
                                          4 : y1:=w;
                                          6 : x2:=w;
                                          8 : y2:=w;
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
                      if b then winC.caption:=s;
                end;
       end;
  end;
close(fi);
end;




end.