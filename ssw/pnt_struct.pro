pro pnt_struct, PNT_Data = PNT_Data
   
   
;+
;       NAME:
;               PNT_STRUCT
;       PURPOSE:
;               Define the following PNT specific database structures
;                       * PNT_Data_Rec
;
;       CALLING SEQUENCE:
;               PNT_STRUCT
;       HISTORY:
;               written by Mons Morrison, Feb 92. 
;
;-
   
   
PNT_Data = { PNT_Data_Rec,              $
                                             ;NOTE: See ATT_STRUCT for details on definitions.
                                             ;
      index_version : FIX('A011'x),  $       ;
                                             ; 00- Index structure version
                                             ;
                                             ;
      time: LONG(0),  $                      ;  2- Major frame time (millisec of day)
      day: FIX(0),  $                        ;  6- Major frame day (since 1-Jan-79)
                                             ;
      iru: LONARR(3),  $                     ;  8- Inertial Reference Unit
      TFSS: INTARR(2),  $                    ; 20- Two-Dimensional Fine Sun Sensor
      hxa: INTARR(4),  $                     ; 24- HXT Aspect sensor
                                             ;       (0) = low address for x
                                             ;       (1) = high address for x
                                             ;       (2) = low address for y
                                             ;       (3) = high address for y
      sc_pntg: LONARR(3),  $                 ; 32- X,Y,Z euler angles in sun pointing coordinates
      status: BYTE(0),  $                    ; 44- b0 - Set if flare mode
                                             ;     b1:2 - DP rate - "non-standard" convention
                                             ;               0 = low
                                             ;               1 = medium
                                             ;               2 = high
                                             ;
                                             ;     b3 - HXA data present (set if present)
      ads: BYTE(0),  $                       ; 45- b0 - Set if ADS results were inserted into the record
                                             ;
      spare: BYTARR(2) }                     ; 46-
   
   
   
  
  
end
