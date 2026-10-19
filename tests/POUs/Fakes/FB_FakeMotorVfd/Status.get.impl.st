IF xFault THEN
    Status := PL.E_Ne107Status.Failure;
ELSE
    Status := eStatus;
END_IF
