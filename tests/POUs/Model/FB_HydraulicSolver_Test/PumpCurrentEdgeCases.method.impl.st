coUnit.TEST('HydraulicSolver_PumpCurrentEdgeCases');

AssertEquals_REAL(Expected := 0.0, Actual := F_PumpCurrent(rFlow_m3h := 100.0, rHead_m := 20.0, rSpeed := 0.0,
                  stPump := stPump), Delta := 0.0, Message := 'speed 0 -> 0 A');
uBits.dwValue := DW_NAN;
AssertEquals_REAL(Expected := 0.0, Actual := F_PumpCurrent(rFlow_m3h := uBits.rValue, rHead_m := 20.0, rSpeed := 1.0,
                  stPump := stPump), Delta := 0.0, Message := 'NaN flow -> 0 A');
// ref: hydraulic.unequal_100_60.i2_a
AssertEquals_REAL(Expected := 5.548032, Actual := F_PumpCurrent(rFlow_m3h := 0.01, rHead_m := 12.42, rSpeed := 0.6,
                  stPump := stPump), Delta := R_EPS_I, Message := 'near-zero flow current');
AssertEquals_REAL(Expected := 5.548032, Actual := F_PumpCurrent(rFlow_m3h := 0.0, rHead_m := 12.42, rSpeed := 0.6,
                  stPump := stPump), Delta := R_EPS_I, Message := 'zero flow current');
stPump.rPnom_kW := 0.0;
AssertEquals_REAL(Expected := 0.0, Actual := F_PumpCurrent(rFlow_m3h := 100.0, rHead_m := 20.0, rSpeed := 1.0,
                  stPump := stPump), Delta := 0.0, Message := 'Pnom 0 -> 0 A');

coUnit.TEST_FINISHED();
