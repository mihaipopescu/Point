UNIT Keyboard;



INTERFACE



   FUNCTION AltPress: Boolean;
   FUNCTION CapsOn: Boolean;
   FUNCTION CtrlPress: Boolean;
   FUNCTION InsertOn: Boolean;
   FUNCTION LAltPress: Boolean;
   FUNCTION LCtrlPress: Boolean;
   FUNCTION LShiftPress: Boolean;
   FUNCTION NumOn: Boolean;
   FUNCTION RAltPress: Boolean;
   FUNCTION RCtrlPress: Boolean;
   FUNCTION RShiftPress: Boolean;
   FUNCTION ScrollOn: Boolean;
   FUNCTION ShiftPress: Boolean;

   PROCEDURE ClearKbd;
   PROCEDURE PrintScreen;
   PROCEDURE SetCaps (CapsLock: Boolean);
   PROCEDURE SetEnhKbd (Enhanced: Boolean);
   PROCEDURE SetInsert (Ins: Boolean);
   PROCEDURE SetNum (NumLock: Boolean);
   PROCEDURE SetPrtSc (PrtScOn: Boolean);
   PROCEDURE SetScroll (ScrollLock: Boolean);
   PROCEDURE SpeedKey (RepDelay, RepRate: Integer);
   PROCEDURE TypeIn (Keys: String);



{ --------------------------------------------------------------------------- }



IMPLEMENTATION



{$F+}

{ the routines are actually in assembly language }

   FUNCTION AltPress; external;
   FUNCTION CapsOn; external;
   FUNCTION CtrlPress; external;
   FUNCTION InsertOn; external;
   FUNCTION LAltPress; external;
   FUNCTION LCtrlPress; external;
   FUNCTION LShiftPress; external;
   FUNCTION NumOn; external;
   FUNCTION RAltPress; external;
   FUNCTION RCtrlPress; external;
   FUNCTION RShiftPress; external;
   FUNCTION ScrollOn; external;
   FUNCTION ShiftPress; external;

   PROCEDURE ClearKbd; external;
   PROCEDURE PrintScreen; external;
   PROCEDURE SetCaps; external;
   PROCEDURE SetEnhKbd; external;
   PROCEDURE SetInsert; external;
   PROCEDURE SetNum; external;
   PROCEDURE SetPrtSc; external;
   PROCEDURE SetScroll; external;
   PROCEDURE SpeedKey; external;
   PROCEDURE TypeIn; external;



{$L Drivers\KBD.obj}



{ ----------------------- initialization code --------------------------- }
BEGIN
END.
