{$X+}
{$F+}

{$ifdef dpmi}
{$C fixed preload permanent}
{$S-}
{$else}
{$O-}
{$endif}

unit task;                  {----==Multitasking==----}

{---------==========---------} Interface {---------==========---------}

uses dos;

Type   TaskProc = Procedure (Var Param);

const  NilTaskPtr : Pointer = nil;

Procedure TaskGetSemaphore(var sem : boolean);
Procedure TaskReleaseSemaphore(var sem : Boolean);
Function  TaskInit(task:taskproc;stacksize: Word;VAR param):byte;
Function  TaskStop (id: byte):byte;
PROCEDURE TaskSwitch;
FUNCTION  TaskID: byte;
function  TaskStackSize:word;
FUNCTION  TasksRunning: byte;
Function  TasksExecuting : Boolean;
Procedure ExecuteTasks;

Implementation

CONST
  maxtasks = 20;
  tasksOK : boolean = false;

TYPE
  taskrecord =
  RECORD
    stackptr  : Pointer;
    stackorg  : Pointer;
    stackbytes: Word;
    bp         : Word;
    id         : byte;
    END;

VAR
  ntasks: byte;
  taskinfo: ARRAY [1..maxtasks] OF taskrecord;
  lastid    : byte;
  idrollover: Boolean;
  CurrTask: Word;

TYPE
  initialstackrecptr = ^initialstackrec;
  initialstackrec =
    RECORD
    bp        : Word;
    taskaddr : taskproc;
    endtask  : Pointer;
    taskparam: Pointer;
    END;


type
  DispatcherHeader = record
    ReturnInt : Word;
    ReturnOfs : Word;
    FileOfs : LongInt;
    CodeSize : Word;
    FixupSize : Word;
    EntryPts : Word;
    CodeListNext : Word;
    LoadSegment : Word;
    Reprieved : Word;
    LoadListNext : Word;
  end;

Procedure TaskGetSemaphore(var sem : boolean);
begin
     While sem do TaskSwitch;
     sem := true;
end;

Procedure TaskReleaseSemaphore(var sem : Boolean);
begin
     sem := false;
     TaskSwitch;
end;

FUNCTION FindTask (targetid: byte): byte;
VAR
  n: Word;
BEGIN
  n := 1;
  WHILE (n <= ntasks) AND (taskinfo [n].id <> targetid) DO
    Inc (n);
  IF (n > ntasks) THEN
    n := 0;
  FindTask := n
END;

PROCEDURE deletetaskinfo (tasknum: byte);
VAR
  i: Word;
BEGIN
  FOR i := tasknum TO pred(ntasks) DO
    taskinfo [i] := taskinfo [succ(i)];
  Dec (ntasks)
END;

PROCEDURE terminateCurrentTask;
CONST
  oldstackorg  : Pointer = NIL;
  oldstackbytes: Word = 0;

VAR
  tasknum : byte;
  newstack: Pointer;
  newbp   : Word;

BEGIN

  IF ntasks <= 1 THEN
    Halt;

  WITH taskinfo [CurrTask] DO
    BEGIN
    oldstackorg   := stackorg;
    oldstackbytes := stackbytes
    END;

  deletetaskinfo (CurrTask);
  IF CurrTask > ntasks THEN
    CurrTask := 1;

  WITH taskinfo [CurrTask] DO
    BEGIN
    newstack := stackptr;
    newbp    := bp
    END;
  INLINE
    (
    $8b/$86/>newstack+0/
    $8b/$96/>newstack+2/
    $8b/$ae/>newbp/
    $fa/
    $8e/$d2/
    $8b/$e0/
    $fb
    );

  IF oldstackbytes > 0 THEN
    FreeMem (oldstackorg, oldstackbytes)
END;

function TaskStop (id: byte):byte;
VAR
  tasknum:byte;

BEGIN
  TaskStop := 0;
  IF id = 0 THEN
    terminatecurrenttask
  ELSE
    BEGIN
    tasknum := FindTask (id);
    IF tasknum = 0 THEN
      TaskStop := 6
    ELSE
      IF tasknum = CurrTask THEN
        terminatecurrenttask
      ELSE
      begin
          WITH taskinfo [tasknum] DO
               IF stackbytes > 0 THEN
                  FreeMem (stackorg, stackbytes);
          deletetaskinfo (tasknum);
          IF CurrTask > tasknum THEN  Dec (CurrTask);
      end;
    END
END;

function TaskInit(task:taskproc;stacksize: Word;VAR param):byte;
VAR
  tasknum: byte;
  stackofs: Word;

BEGIN
     TaskInit := 0;
     IF ntasks >= maxtasks THEN
         DOSError := 20
     ELSE
     BEGIN
          tasknum := Succ (ntasks);

          IF stacksize < 1024 THEN
          stacksize := 1024;
          IF stacksize > MaxAvail THEN
          begin
               DosError := 20;
               exit;
          end
          ELSE
              WITH taskinfo [tasknum] DO
              BEGIN
                   GetMem (stackorg, stacksize);
                   stackbytes := stacksize
          END;

          WITH taskinfo [tasknum] DO
          BEGIN
               stackofs := Ofs (stackorg^) + stackbytes - Sizeof (initialstackrec);
               stackptr := Ptr (Seg (stackorg^), stackofs);
               bp := Ofs (stackptr^);
               WITH initialstackrecptr (stackptr)^ DO
               BEGIN
                    taskparam := @param;
                    taskaddr  := task;
                    endtask   := @terminatecurrenttask;
                    bp         := 0
               END;

               IF lastid = 255 THEN
               BEGIN
                    lastid := 2;
                    idrollover := True
               END
               ELSE
                   Inc (lastid);
               IF idrollover THEN
               WHILE (FindTask (lastid) <> 0) DO
               begin
                    IF lastid = 255 THEN
                    BEGIN
                         lastid := 2;
                         idrollover := True
                    END
                    ELSE
                        Inc (lastid);
               end;
               id := lastid;
               taskinfo [tasknum].id := id
          END;
          Inc (ntasks);
          TaskInit := LastID;
     end;
END;

PROCEDURE TaskSwitch;

VAR
  newstack: Pointer;
  oldbp   : Word;
  newbp   : Word;

BEGIN
  IF ntasks > 1 THEN
    BEGIN

    INLINE($89/$ae/>oldbp);

    WITH taskinfo [CurrTask] DO
      BEGIN
      stackptr := Ptr (Sseg, Sptr);
      bp        := oldbp
      END;

    IF CurrTask >= ntasks THEN
      CurrTask := 1
    ELSE
      Inc (CurrTask);
    WITH taskinfo [CurrTask] DO
      BEGIN
      newstack := stackptr;
      newbp    := bp
      END;

    INLINE(
      $8b/$86/>newstack+0/
      $8b/$96/>newstack+2/
      $8b/$ae/>newbp/
      $Fa/
      $8e/$d2/
      $8b/$e0/
      $fb)
    END
END;


FUNCTION TaskID: byte;
BEGIN
  TaskID := taskinfo [CurrTask].id
END;

function TaskStackSize:word;
begin
     TaskStackSize := taskinfo [CurrTask].stackbytes;
end;

FUNCTION TasksRunning: byte;
BEGIN
  TasksRunning := pred(ntasks);
END;

Function TasksExecuting : Boolean;
begin
     TasksExecuting := (ntasks > 1);
end;

Procedure ExecuteTasks;
begin
     While (Ntasks > 1) do TaskSwitch;
end;

BEGIN
  ntasks := 1;
  CurrTask := 1;
  WITH taskinfo [CurrTask] DO
    BEGIN
    stackorg   := NIL;
    stackbytes := 0;
    id         := 1;
    END;
  lastid := 1;
  idrollover := False
end.

