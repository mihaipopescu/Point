{
Turbo Pascal Compiler Directives
}


{$DEFINE i286}
{$DEFINE DEBUGGING}

{$A+}                   { Data Alignment........Word                  }
{$I-}                   { I/O Checking..........Off                   }
{$X+}                   { Enhanced Syntax.......On                    }
{$V-}                   { String Type Checking..Relaxed               }
{$P-}                   { Open Strings..........Off                   }
{$T-}                   { @ Pointers............UnTyped               }
{$F+}                   { Far Calls.............On                    }

{$IFDEF i286}
{$G+}                   { 286 OpCodes...........On                    }
{$ELSE}
{$G-}                   { 286 OpCodes...........Off                   }
{$ENDIF}


{$IFDEF OVERLAYS}
{$O+}                   { Overlays Allowed......Yes                   }
{$ELSE}
{$O-}                   { Overlays Allowed......No                    }
{$ENDIF}

{$IFDEF DEBUGGING}
{$B+}                   { Boolean Evaluation....Complete              }
{$D+}                   { Debugging Info........On                    }
{$L+}                   { Line Numbers..........On                    }
{$Y+}                   { Symbol Information....On                    }
{$R+}                   { Range Checking........On                    }
{$S+}                   { Stack Checking........On                    }
{$Q+}                   { Overflow Checking.....On                    }
{$ELSE}
{$B-}                   { Boolean Evaluation....Short Circuit         }
{$D-}                   { Debugging Info........Off                   }
{$L-}                   { Line Numbers..........Off                   }
{$Y-}                   { Symbol Information....Off                   }
{$R-}                   { Range Checking........Off                   }
{$S-}                   { Stack Checking........Off                   }
{$Q-}                   { Overflow Checking.....Off                   }
{$ENDIF}
