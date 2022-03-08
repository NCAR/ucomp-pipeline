pro fem_old_struct, FEM_9001_Data = FEM_9001_Data,  $
                     FEM_9002_Data = FEM_9002_Data
   
   
;+
;       NAME:
;               FEM_OLD_STRUCT
;       PURPOSE:
;               Define the following FEM (S/C transition) specific database structures
;                       * FEM_9001_Data_Rec
;
;       CALLING SEQUENCE:
;               FEM_OLD_STRUCT
;       HISTORY:
;               Written 22-Nov-91 by M.Morrison
;
;-
   
   
FEM_9001_Data = { FEM_9001_Data_Rec,              $
      index_version : FIX('9001'x),  $       ;
                                             ;
                                             ;       One record per S/C day
                                             ;       15 orbits per 24 hours
                                             ;       105 orbits per week
                                             ;       5460 orbits per year
      time: LONG(0),  $                      ; 00- Beginning of S/C day (Millisec of day)
                                             ;     (True predicted start time, no margin worked
                                             ;     in like the FileID has)
      day: FIX(0),  $                        ; 04- Beginning of S/C day (days since 1-Jan-79)
                                             ;
      night: FIX(0),  $                      ; 06- Start of S/C night in seconds from S/C day
      st_saa: FIX(0),  $                     ; 08- Start of S/C SAA in seconds from S/C day
      en_saa: FIX(0),  $                     ; 10- End of S/C SAA in seconds from S/C day
                                             ;
      st_station: INTARR(3),  $              ; 12- Start of station contact in seconds from S/C day
                                             ;       (i) = can be three station contacts in one day
      en_station: INTARR(3),  $              ; 16- End of station contact in seconds from S/C day
                                             ;       (i) = can be three station contacts in one day
      st$station: BYTARR(3),  $              ; 20- Station 
                                             ;               'U' = KSC
                                             ;               'C' = Canberra
                                             ;               'M' = Madrid
                                             ;               'G' = Goldstone
                                             ;       (i) = can be three station contacts in one day
      st$antenna: BYTARR(3,2),  $            ; 26- Antenna to be used (A or B)
                                             ;       (i,j)
                                             ;       (i) = can be three station contacts in one day
                                             ;       (j) = can be two antenna uses per contact
      cng_antenna: INTARR(3),  $             ; 22- Time that the antenna must be changed in
                                             ;     seconds from S/C day.  If the antenna is not
                                             ;     changed, then these values are zero
                                             ;       (i) = can be three station contacts in one day
      use_station: BYTARR(3),  $             ; 30- Whether the station was actually used for a down
                                             ;     link or not (0=no, 1=yes)
                                             ;     DERIVED AFTER DOWNLINK BY LOOKING AT SIRIUS DATA
                                             ;
      sc_rev: FIX(0),  $                     ; 30- Spacecraft revolution number
                                             ;     This is actually only the number of S/C day/night
                                             ;     transitions
      week: BYTE(0),  $                      ; 32- Week number (1-53)
      year: BYTE(0),  $                      ; 33- year (91,92,...)
      iday: BYTE(0),  $                      ; 34- Day within the week (0-6)
      day_rev: BYTE(0),  $                   ; 35- Revolution number within the day (1-15)
                                             ;
      st$fileid: BYTARR(13),  $              ; 36- The master fileid for this orbit
                                             ;     The FileID time is approximately 5 minutes before
                                             ;     the true S/C day time.  This is the time used for
                                             ;     extraction to insure that data in one orbit is not
                                             ;     broken across files.
                                             ;
      spare: BYTARR(1) }                     ; 49- Spare
   
   
   
FEM_9002_Data = { FEM_9002_Data_Rec,              $
      path: FIX(0),  $                       ; 00- The SIRIUS mainframe path ID (only the last
                                             ;     4 characters since the date is the first
                                             ;     6 characters (yyddmm)
      time: LONG(0),  $                      ; 00- Beginning of S/C day (Millisec of day)
                                             ;     (True predicted start time, no margin worked
                                             ;     in like the FileID has)
      day: FIX(0),  $                        ; 04- Beginning of S/C day (days since 1-Jan-79)
                                             ;
      night: FIX(0),  $                      ; 06- Start of S/C night in seconds from S/C day
      st_saa: FIX(0),  $                     ; 08- Start of S/C SAA in seconds from S/C day
      en_saa: FIX(0),  $                     ; 10- End of S/C SAA in seconds from S/C day
                                             ;
      st_station: INTARR(3),  $              ; 12- Start of station contact in seconds from S/C day
                                             ;       (i) = can be three station contacts in one day
      en_station: INTARR(3),  $              ; 16- End of station contact in seconds from S/C day
                                             ;       (i) = can be three station contacts in one day
      st$station: BYTARR(3),  $              ; 20- Station 
                                             ;               'U' = KSC
                                             ;               'C' = Canberra
                                             ;               'M' = Madrid
                                             ;               'G' = Goldstone
                                             ;       (i) = can be three station contacts in one day
      st$antenna: BYTARR(3,2),  $            ; 26- Antenna to be used (A or B)
                                             ;       (i,j)
                                             ;       (i) = can be three station contacts in one day
                                             ;       (j) = can be two antenna uses per contact
      cng_antenna: INTARR(3),  $             ; 22- Time that the antenna must be changed in
                                             ;     seconds from S/C day.  If the antenna is not
                                             ;     changed, then these values are zero
                                             ;       (i) = can be three station contacts in one day
      use_station: BYTARR(3),  $             ; 30- Whether the station was actually used for a down
                                             ;     link or not (0=no, 1=yes)
                                             ;     DERIVED AFTER DOWNLINK BY LOOKING AT SIRIUS DATA
                                             ;
      sc_rev: FIX(0),  $                     ; 30- Spacecraft revolution number
                                             ;     This is actually only the number of S/C day/night
                                             ;     transitions
      week: BYTE(0),  $                      ; 32- Week number (1-53)
      year: BYTE(0),  $                      ; 33- year (91,92,...)
      iday: BYTE(0),  $                      ; 34- Day within the week (0-6)
      day_rev: BYTE(0),  $                   ; 35- Revolution number within the day (1-15)
                                             ;
      st$fileid: BYTARR(13),  $              ; 36- The master fileid for this orbit
                                             ;     The FileID time is approximately 5 minutes before
                                             ;     the true S/C day time.  This is the time used for
                                             ;     extraction to insure that data in one orbit is not
                                             ;     broken across files.
                                             ;
      spare: BYTARR(1) }                     ; 49- Spare
   
   
   
  
  
end
