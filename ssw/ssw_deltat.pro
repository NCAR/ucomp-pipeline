function ssw_deltat, t0, t1, $
   seconds=seconds, minutes=minutes, hours=hours, days=days, loud=loud, $
   reference=reference

;+
;   Name: ssw_deltat
;
;   Purpose: return deltaTime between input times in specified units
;      
;   Input Parameters:
;       t0 - start time OR a vector of times - any SSW format
;       t1 - optional end time if t0 is scalar  [output is d(timegrange) ]
;
;   Output:
;      Function returns delta-time in specified units (default seconds)
;      n_elements(output) = n_elements(inputtimes)-1
;  -OR-                   = n_elements(inputtimes) if REFERENCE specified
;                                            
;   Keyword Parameters:
;      SECONDS,MINUTES,HOURS,DAYS  - output units (default=seconds)
;      reference - optional reference time for compare (any SSW format)
;  
;   Calling Sequence:
;      dt=ssw_deltat(t0,t1)			; explicit start and stop time
;      dt=ssw_deltat(times)			; vector of times   
;      dt=ssw_deltat(times, reference=reftime)  ; dTimes/dReference
;  
;   Calling Examples:
;      dt=ssw_delta(index)                           ; dT (between elements) 
;      dt=ssw_delta('1-feb-98', '23-mar-02', /days)  ; dT (time range)
;      dt=ssw_deltat(index, reference='3-apr-1998')  ; dT/dREFERENCE
;
;   Illustration [ timegrid and ssw_deltat ]
;
;   IDL> tgrid=timegrid('1-feb',nsamp=3,hours=48)    ; make dummy time array
;   IDL> more,anytim(tgrid,/ecs)
;     1998/02/01 00:00:00.000
;     1998/02/03 00:00:00.000
;     1998/02/05 00:00:00.000
;
;   IDL> more,ssw_deltat(tgrid,ref='2-feb',/days)    ; show dT/dREF
;        -1.0000000
;         1.0000000
;         3.0000000
;  
;   History:
;      Circa 1-jan-1997 - S.L.Freeland
;      25-May-1998 - S.L.Freeland use <anytim> in place of <anytim2ints>  
;       3-Dec-1998 - S.L.Freeland - add REFERENCE and some documentation
;-

case n_params() of 
   0: message,"Need input timess..."
   1: times=t0
   2: times=[anytim(t0(0)),anytim(t1(0))]
   else:
endcase

case 1 of
   keyword_set(seconds): factor=1.
   keyword_set(minutes): factor=1./60.
   keyword_set(hours): factor=1./(60.*60.)
   keyword_set(days): factor=1./(60.*60.*24)
   else: factor=1.0
endcase

case 1 of
  keyword_set(reference): $
       deltat=( anytim(times,/tai) - anytim(reference,/tai) )*factor
  else:deltat=deriv_arr(anytim(times,/tai))*factor
endcase

if n_elements(deltat) eq 1 then deltat=deltat(0)
return,deltat
end
