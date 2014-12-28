Unit XMSArray;

{ Author: Bean, thitt@igateway.com }
{ This code is hereby released to the public domain }
{ Use this code at YOUR own risk, Hey it works for me :) }
{ Version 1.0 07-20-98 }
{ Version 1.1 07-20-98 }
{   Added Resize function }

{$X+}

INTERFACE

{ All functions return True is successful or False if not successful }
{ If you don't want to check if successful use the extended syntax $X+ }
{ compiler directive. }
{ *** NOTE: All number of bytes to move MUST be an even number }

Type
  XMSHandle = Word;

Function XMSExist: Boolean;
{ Returns true is XMS memory is supported }

Function XMSVersion: Word;
{ Returns the XMSVersion in BCD. Version 3.0 would return 768 }

Function XMSMemAvail: LongInt;
{ Returns total amount of XMS memory available in bytes }

Function XMSMaxAvail: LongInt;
{ Returns the size of the largest block of XMS memory avaible }
{  This would be the max size that a single handle could point to }

Function XMSGetMem(Var Handle: XMSHandle; NumBytes: LongInt): Boolean;
{ Used to allocate XMS memory. The returned handle is used to access and/or }
{  free the XMS memory }

Function XMSResize(Handle: XMSHandle; NumBytes: LongInt): Boolean;
{ Used to shink or enlarge a XMS memory handle. }

Function XMSMoveTo(Var Source; DestHandle: XMSHandle; NumBytes: LongInt): Boolean;
{ Moves bytes from conventional memory to start of XMS memory block }

Function XMSMoveToOfs(Var Source; DestHandle: XMSHandle; DestOfs, NumBytes: LongInt): Boolean;
{ Moves bytes from conventional memory to an offset in an XMS memory block }

Function XMSMoveFrom(SourceHandle: XMSHandle; Var Dest; NumBytes: LongInt): Boolean;
{ Moves bytes from start of XMS block to conventional memory }

Function XMSMoveFromOfs(SourceHandle: XMSHandle; SourceOfs: LongInt; Var Dest; NumBytes: LongInt): Boolean;
{ Moves bytes from offset on XMS block to conventional memory }

Function XMSFreeMem(Handle: XMSHandle): Boolean;
{ Releases allocated XMS memory. NOTE: XMS memory is NOT freed automatically }
{  When your program ends. You MUST explicitly free it ! }

Type
  { TXMSArray is an object oriented way of using a block of XMS as a }
  {  one dimensional array. }
  { After calling Init check if Handle is zero, if so the array could }
  {  NOT be create. In other words Handle should not be zero. }
  { NOTE: DataSize MUST be an EVEN number }
  { NOTE: Elements are numbered 0 though n-1 }
  PXMSArray = ^TXMSArray;
  TXMSArray = Object
    Handle: XMSHandle;
    Elements: LongInt;
    DataSize: LongInt;
    Constructor Init(GElements, GDataSize: LongInt);
    Destructor Done; Virtual;
    Function Resize(GElements: LongInt): Boolean;
    Function SetElement(GElement: LongInt; Var Data): Boolean;
    Function GetElement(GElement: LongInt; Var Data): Boolean;
  End;

  { TXMS2DArray is an object oriented way of using a block of XMS as a }
  {  two dimensional array. }
  { After calling Init check if Handle is zero, if so the array could }
  {  NOT be create. In other words Handle should not be zero. }
  { NOTE: DataSize MUST be an EVEN number }
  { NOTE: Elements are numbered 0 though n-1 }
  PXMS2DArray = ^TXMS2DArray;
  TXMS2DArray = Object
    Handle: XMSHandle;
    Rows, Columns: LongInt;
    DataSize: LongInt;
    Constructor Init(GRows, GColumns, GDataSize: LongInt);
    Destructor Done; Virtual;
    Function Resize(GRows: LongInt): Boolean;
    Function SetElement(GRow, GColumn: LongInt; Var Data): Boolean;
    Function GetElement(GRow, GColumn: LongInt; Var Data): Boolean;
  End;

IMPLEMENTATION

Var
  XMSOk: Boolean;
  Version: Word;
  XMSEntry: Pointer;
  XMSMoveRecd: Record
    XMS_Size: LongInt;
    XMS_SrcH: XMSHandle;
    XMS_SrcOfs: LongInt;
    XMS_DestH: XMSHandle;
    XMS_DestOfs: LongInt;
  End;

Function XMSInit(Var Version: Word): Boolean;
Var
  XMSHere: Boolean;
  Ver: Word;
Begin
  Asm
    MOV XMSHere,0  { Assume failure }
    MOV Ver,0
    MOV AX,4300H   { 4300 = Check XMS }
    INT 2FH        { Interrupt returns 80 in AL if XMS exists }
    CMP AL,80H
    JNE @NOXMS
    MOV XMSHere,1  { Set flag to true }
    MOV AX,4310H   { 4310 = Get XMS calling address }
    INT 2FH        { Returns calling address in ES:BX }
    MOV DS:[OFFSET XMSEntry],BX { Save calling address }
    MOV DS:[OFFSET XMSEntry+2],ES
    XOR AX,AX      { Zero AX }
    CALL DS:[XMSEntry] { Call XMS to get version }
    MOV Ver,AX     { Store version number }
  @NOXMS:
  End;
  Version:=Ver;
  XMSInit:=XMSHere;
End;

Function XMSExist: Boolean;
Begin
  XMSExist:=XMSOk;
End;

Function XMSVersion: Word;
Begin
  XMSVersion:=Version;
End;

Function XMSMemAvail: LongInt; { Returns zero if no XMS available }
Var
  SizeInK: Word;
Begin
  If Not XMSOk Then XMSMemAvail:=0
  Else
  Begin
    Asm
      MOV AH,8
      CALL DS:[XMSEntry]
      MOV SizeInK,DX
    End;
    XMSMemAvail:=LongInt(SizeInK) * 1024; { Convert K to bytes }
  End;
End;

Function XMSMaxAvail: LongInt;
Var
  SizeInK: Word;
Begin
  If Not XMSOk Then XMSMaxAvail:=0
  Else
  Begin
    Asm
      MOV AH,8
      CALL DS:[XMSEntry]
      MOV SizeInK,AX
    End;
    XMSMaxAvail:=LongInt(SizeInK) * 1024; { Convert K to bytes }
  End;
End;

Function XMSGetMem(Var Handle: XMSHandle; NumBytes: LongInt): Boolean;
Var
  GetOk: Boolean;
  Hand: Word;
  SizeInK: Word;
Begin
  If Not XMSOk Then XMSGetMem:=False
  Else
  Begin
    { XMS allocates in KBytes to find size in K }
    SizeInK:=Succ(Pred(NumBytes) Div 1024);
    Asm
      MOV GetOk,0  { Assume No Good }
      MOV DX,SizeInK
      MOV AH,9
      CALL DS:[XMSEntry]
      OR AX,AX
      JZ @NoGood
      MOV Hand,DX
      MOV GetOk,1
    @NoGood:
    End;
    Handle:=Hand;
    XMSGetMem:=GetOk;
  End;
End;

Function XMSResize(Handle: XMSHandle; NumBytes: LongInt): Boolean;
Var
  ResizeOk: Boolean;
  Hand: Word;
  SizeInK: Word;
Begin
  If Not XMSOk Then XMSResize:=False
  Else
  Begin
    { XMS allocates in KBytes to find size in K }
    SizeInK:=Succ(Pred(NumBytes) Div 1024);
    Asm
      MOV ResizeOk,0  { Assume No Good }
      MOV DX,Handle
      MOV BX,SizeInK
      MOV AH,$0f
      CALL DS:[XMSEntry]
      OR AX,AX
      JZ @NoGood
      MOV ResizeOk,1
    @NoGood:
    End;
    XMSResize:=ResizeOk;
  End;
End;

Function XMSMove(SourceHandle: XMSHandle; SourceOfs: LongInt;
                 DestHandle: XMSHandle; DestOfs: LongInt; Count: LongInt): Boolean;
Var
  MoveOk: Boolean;
Begin
  MoveOk:=False;
  If XMSOk and Not Odd(Count) Then
  Begin
    With XMSMoveRecd Do
    Begin
      XMS_Size:=Count;
      XMS_SrcH:=SourceHandle;
      XMS_SrcOfs:=SourceOfs;
      XMS_DestH:=DestHandle;
      XMS_DestOfs:=DestOfs;
    End;
    Asm
      MOV SI,OFFSET XMSMoveRecd
      MOV AH,0Bh
      CALL DS:[XMSEntry]
      OR AX,AX
      JZ @NoGood
      MOV MoveOk,1
    @NoGood:
    End;
  End;
  XMSMove:=MoveOk;
End;

Function XMSMoveTo(Var Source; DestHandle: XMSHandle; NumBytes: LongInt): Boolean;
Begin
  XMSMoveTo:=XMSMoveToOfs(Source, DestHandle, 0, NumBytes);
End;

Function XMSMoveToOfs(Var Source; DestHandle: XMSHandle; DestOfs, NumBytes: LongInt): Boolean;
Begin
  XMSMoveToOfs:=XMSMove(0, LongInt(@Source), DestHandle, DestOfs, NumBytes);
End;

Function XMSMoveFrom(SourceHandle: XMSHandle; Var Dest; NumBytes: LongInt): Boolean;
Begin
  XMSMoveFrom:=XMSMoveFromOfs(SourceHandle, 0, Dest, NumBytes);
End;

Function XMSMoveFromOfs(SourceHandle: XMSHandle; SourceOfs: LongInt; Var Dest; NumBytes: LongInt): Boolean;
Begin
  XMSMoveFromOfs:=XMSMove(SourceHandle, SourceOfs, 0, LongInt(@Dest), NumBytes);
End;

Function XMSFreeMem(Handle: XMSHandle): Boolean;
Begin
  If Not XMSOk Then XMSFreeMem:=False Else
  Begin
    Asm
      MOV DX,Handle
      MOV AH,0Ah
      CALL DS:[XMSEntry]
    End;
    XMSFreeMem:=True;
  End;
End;

{ **************************************************************** }

Constructor TXMSArray.Init(GElements: LongInt; GDataSize: LongInt);
Begin
  Elements:=GElements;
  DataSize:=GDataSize;
  If Odd(DataSize) or Not XMSGetMem(Handle, Elements * DataSize) Then
  Begin
    Handle:=0;
  End;
End;

Destructor TXMSArray.Done;
Begin
  XMSFreeMem(Handle);
  Handle:=0;
End;

Function TXMSArray.Resize(GElements: LongInt): Boolean;
Begin
  If XMSResize(Handle, GElements * DataSize) Then
  Begin
    Elements:=GElements;
    Resize:=True;
  End
  Else Resize:=False;
End;

Function TXMSArray.SetElement(GElement: LongInt; Var Data): Boolean;
Begin
  {$IFOPT R+}
  If GElement >= Elements Then RunError(201);
  {$ENDIF}
  SetElement:=XMSMoveToOfs(Data, Handle, GElement * DataSize, DataSize);
End;

Function TXMSArray.GetElement(GElement: LongInt; Var Data): Boolean;
Begin
  {$IFOPT R+}
  If GElement >= Elements Then RunError(201);
  {$ENDIF}
  GetElement:=XMSMoveFromOfs(Handle, GElement * DataSize, Data, DataSize);
End;

{ **************************************************************** }

Constructor TXMS2DArray.Init(GRows, GColumns: LongInt; GDataSize: LongInt);
Begin
  Rows:=GRows;
  Columns:=GColumns;
  DataSize:=GDataSize;
  If Odd(DataSize) or Not XMSGetMem(Handle, Columns * Rows * DataSize) Then
  Begin
    Handle:=0;
  End;
End;

Destructor TXMS2DArray.Done;
Begin
  XMSFreeMem(Handle);
  Handle:=0;
End;

Function TXMS2DArray.Resize(GRows: LongInt): Boolean;
Begin
  If XMSResize(Handle, GRows * Columns * DataSize) Then
  Begin
    Rows:=GRows;
    Resize:=True;
  End
  Else Resize:=False;
End;

Function TXMS2DArray.SetElement(GRow, GColumn: LongInt; Var Data): Boolean;
Begin
  {$IFOPT R+}
  If (GRow >= Rows) or (GColumn >= Columns) Then RunError(201);
  {$ENDIF}
  SetElement:=XMSMoveToOfs(Data, Handle, GRow * Columns * DataSize + GColumn * DataSize, DataSize);
End;

Function TXMS2DArray.GetElement(GRow, GColumn: LongInt; Var Data): Boolean;
Begin
  {$IFOPT R+}
  If (GRow >= Rows) or (GColumn >= Columns) Then RunError(201);
  {$ENDIF}
  GetElement:=XMSMoveFromOfs(Handle, GRow * Columns * DataSize + GColumn * DataSize, Data, DataSize);
End;

{ **************************************************************** }

Begin { Unit initalization code }
writeln('XMS initializtion ...');
  XMSOk:=XMSInit(Version);
if XMSOk then
   begin
      Writeln('- XMS version ',Version div 100,'.',Version mod 100);
      Writeln('- Total Avaible XMSMemory :  ',XMSMemAvail,' bytes');
      Writeln('- Largest Block XMSMemory :  ',XMSMaxAvail,' bytes');
   end
else begin writeln('XMS initialization failed.');halt;end;
End.


