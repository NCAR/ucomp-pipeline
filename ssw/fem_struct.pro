pro fem_struct, FEM_Data = FEM_Data,  $
                     FEM_Version = FEM_Version
   
   
;+
;       NAME:
;               FEM_STRUCT
;       PURPOSE:
;               Define the following FEM (S/C transition) specific database structures
;                       * FEM_Data_Rec
;                       * FEM_Version_Rec
;
;       CALLING SEQUENCE:
;               FEM_STRUCT
;       HISTORY:
;               Written 22-Nov-91 by M.Morrison
;               23-Mar-95 (MDM) - Changed the structure to hold 6 station contacts
;                                 within a single orbit to handle Wallops
;
;-
   
   
FEM_Data = { FEM_Data_Rec,              $
      path: FIX(0),  $                       ; 00- The SIRIUS mainframe path ID (only the last
                                             ;     4 characters since the date is the first
                                             ;     6 characters (yyddmm)
      time: LONG(0),  $                      ; 04- Beginning of S/C day (Millisec of day)
                                             ;     (True predicted start time, no margin worked
                                             ;     in like the FileID has)
      day: FIX(0),  $                        ; 06- Beginning of S/C day (days since 1-Jan-79)
                                             ;
      night: FIX(0),  $                      ; 08- Start of S/C night in seconds from S/C day
      st_saa: FIX(0),  $                     ; 10- Start of S/C SAA in seconds from S/C day
      en_saa: FIX(0),  $                     ; 12- End of S/C SAA in seconds from S/C day
                                             ;
      st_station: INTARR(6),  $              ; 14- Start of station contact in seconds from S/C day
                                             ;       (i) = can be six station contacts in one day
      en_station: INTARR(6),  $              ; 26- End of station contact in seconds from S/C day
                                             ;       (i) = can be six station contacts in one day
      st$station: BYTARR(6),  $              ; 38- Station 
                                             ;               'U' = KSC
                                             ;               'C' = Canberra
                                             ;               'M' = Madrid
                                             ;               'G' = Goldstone
                                             ;               'W' = Wallops
                                             ;       (i) = can be six station contacts in one day
      use_station: BYTARR(6),  $             ; 44- Whether the station was actually used for a down
                                             ;     link or not (0=no, 1=yes)
                                             ;     DERIVED AFTER DOWNLINK BY LOOKING AT SIRIUS DATA
                                             ;
      sc_rev: FIX(0),  $                     ; 50- Spacecraft revolution number
                                             ;     This is actually only the number of S/C day/night
                                             ;     transitions
      week: BYTE(0),  $                      ; 52- Week number (1-53)
      year: BYTE(0),  $                      ; 53- year (91,92,...)
      iday: BYTE(0),  $                      ; 54- Day within the week (0-6)
      day_rev: BYTE(0),  $                   ; 55- Revolution number within the day (1-15)
                                             ;
      st$fileid: BYTARR(13),  $              ; 56- The master fileid for this orbit
                                             ;     The FileID time is approximately 5 minutes before
                                             ;     the true S/C day time.  This is the time used for
                                             ;     extraction to insure that data in one orbit is not
                                             ;     broken across files.
                                             ;
      spare: BYTARR(11) }                    ; 69- Spare
   
   
   
FEM_Version = { FEM_Version_Rec,              $
      data : FIX('9004'x),  $                ; 02- Data section version number
                                             ;
                                             ;     This structure is not written to any files
      spare: BYTE(0) }                       ;     (need for automatic conversion to IDL format)
   
   
   
  
  
end
