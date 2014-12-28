unit DPMS;              { VESA Display Power Management System (DPMS)}

Interface
        Const
         Mode_On = 0;
         Mode_Standby = 1;
         Mode_Suspend = 2;
         Mode_Off = 4;


        Procedure SetDisplayMode(Mode: Byte);
        function Card_config:boolean;

Implementation

    Uses Dos;
    Var  Regs: Registers;

Procedure SetDisplayMode(Mode: Byte);
Begin
Regs.Ax:= $4f10;
Regs.Bl:= 1;
Regs.Bh:= Mode;
Regs.Es:= 0;
Regs.Di:= 0;
Intr($10,Regs);
End;

Procedure My_ReadKey; Assembler;
Asm
Xor Ax,Ax
Int 16h
End;

function Card_config:boolean;
begin
Regs.Ax:= $4f10;
Regs.Bl:= 0;
Regs.Es:= 0;
Regs.Di:= 0;
Intr($10,regs);
If Regs.Al <> $4F Then
 Card_config:=false else Card_config:=true;
end;

end.