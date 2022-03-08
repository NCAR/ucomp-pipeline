pro obs_struct, Obs_NewOrb_Hd = Obs_NewOrb_Hd,  $
                     Obs2_NewOrb_Hd = Obs2_NewOrb_Hd,  $
                     Obs_NewOrbit = Obs_NewOrbit,  $
                     Obs2_NewOrbit = Obs2_NewOrbit,  $
                     Obs_FileID = Obs_FileID,  $
                     Obs_OrbitSol = Obs_OrbitSol,  $
                     Obs_WBSHXT = Obs_WBSHXT,  $
                     Obs_BCS_Obs = Obs_BCS_Obs,  $
                     Obs_BCS_Status = Obs_BCS_Status,  $
                     Obs_HXT_Status = Obs_HXT_Status,  $
                     Obs_WBS_Status = Obs_WBS_Status,  $
                     Obs_SXT = Obs_SXT
   
   
;+
;       NAME:
;               OBS_STRUCT
;       PURPOSE:
;               Define the following observing log database structures
;                       * Obs_NewOrb_Hd_Rec        
;                       * Obs_NewOrbit_Rec         
;                       * Obs_FileID_Rec           
;                       * Obs_OrbitSol_Rec         
;                       * Obs_WBSHXT_Rec           
;                       * Obs_BCS_Rec              
;                       * Obs_BCS_Status_Rec       
;                       * Obs_HXT_Status_Rec       
;                       * Obs_WBS_Status_Rec       
;                       * Obs_SXT_Rec              
;
;       CALLING SEQUENCE:
;               OBS_STRUCT
;       HISTORY:
;               written by Mons Morrison, Fall 90.
;
;-
   
   
Obs_NewOrb_Hd = { Obs_NewOrb_Hd_Rec,              $
      nOrbitRec: LONG(0),  $                 ; 00- Number of orbit record entries
      spare: BYTARR(28) }                    ;  4- Spares
   
   
   
Obs2_NewOrb_Hd = { Obs2_NewOrb_Hd_Rec,              $
      nOrbitRec: LONG(0),  $                 ; 00- Number of orbit record entries
      NewOrbit_Ver: LONG(0),  $              ;  4- The structure version of the new orbit records
                                             ;       0 = Original {Obs_NewOrbit_Rec}
                                             ;       1 = OBS log pointer {Obs_
      spare: BYTARR(24) }                    ;  4- Spares
   
   
   
Obs_NewOrbit = { Obs_NewOrbit_Rec,              $
      time: LONG(0),  $                      ; 00- Start time of orbit
      day: FIX(0),  $                        ; 04- Stard day of orbit
      StEntry: LONG(0),  $                   ; 06- Pointer to start of orbit of data
                                             ;     in entry number (ie 32 or 48 byte blocks)
                                             ;     from the beginning of the data section.
                                             ;     The counter starts at 1.
      spare: BYTARR(6) }                     ; 10- Spares
   
   
   
Obs2_NewOrbit = { Obs2_NewOrbit_Rec,              $
      time: LONG(0),  $                      ; 00- Start time of orbit
      day: FIX(0),  $                        ; 04- Stard day of orbit
      StEntry: LONG(0),  $                   ; 06- Pointer to start of orbit of data
                                             ;     in entry number (ie 32 or 48 byte blocks)
                                             ;     from the beginning of the data section.
                                             ;     The counter starts at 1.
                                             ;
      st$fileId: BYTARR(13),  $              ; 10- File ID for the orbit worth of data
                                             ;
      sxt_pfi: LONG(0),  $                   ; 23- First SXT PFI Image serial number in the FileID
                                             ;     (if zero, there are no images for that fileID)
      sxt_ffi: LONG(0),  $                   ; 27- First SXT FFI Image serial number in the FileID
                                             ;     (if zero, there are no images for that fileID)
                                             ;
      delta_min: FIX(0),  $                  ; 31- Number of minutes covered by this FileID
      spare: BYTARR(15) }                    ; 33- Spare
   
   
   
Obs_FileID = { Obs_FileID_Rec,              $
      entry_type: BYTE(0),  $                ; 00- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 01- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 05- Major frame day (since 1-Jan-79)  
                                             ;
      st$fileId: BYTARR(13),  $              ; 07- File ID for the orbit worth of data
                                             ;
      sxt_pfi: LONG(0),  $                   ; 20- First SXT PFI Image serial number in the FileID
                                             ;     (if zero, there are no images for that fileID)
      sxt_ffi: LONG(0),  $                   ; 24- First SXT FFI Image serial number in the FileID
                                             ;     (if zero, there are no images for that fileID)
                                             ;
      delta_min: FIX(0),  $                  ; 28- Number of minutes covered by this FileID
      spare: BYTARR(2) }                     ; 30- Spare
   
   
   
Obs_OrbitSol = { Obs_OrbitSol_Rec,              $
      entry_type: BYTE(0),  $                ; 00- Observing Log Entry Type/Version
                                             ;
      epoch_time: LONG(0),  $                ; 01- Epoch time (millisec of day)
      epoch_day: FIX(0),  $                  ; 05- Epoch day (since 1-Jan-79)
                                             ;
      sol_time: LONG(0),  $                  ; 07- Solution time (millisec of day)
      sol_day: FIX(0),  $                    ; 11- Solution day (since 1-Jan-79)
                                             ;
      x: FLOAT(0),  $                        ; 13- (km)
      y: FLOAT(0),  $                        ; 17- (km)
      z: FLOAT(0),  $                        ; 21- (km)
      xdot: FLOAT(0),  $                     ; 25- (km/s)
      spare1: BYTARR(3),  $                  ; 29- Spare
                                             ;
      cont_mark1 : BYTE(255),  $             ; 32- Continuation of an entry mark
      ydot: FLOAT(0),  $                     ; 33- (km/s)
      zdot: FLOAT(0),  $                     ; 37- (km/s)
      pin: FLOAT(0),  $                      ; 41- (deg.n)??
      h: FLOAT(0),  $                        ; 45- (km)
                                             ;
      a: FLOAT(0),  $                        ; 49- (km)
      e: FLOAT(0),  $                        ; 53- 
      i: FLOAT(0),  $                        ; 57- (deg)
      spare2: BYTARR(3),  $                  ; 61- Spare
                                             ;
      cont_mark2 : BYTE(255),  $             ; 64- Continuation of an entry mark
      an: FLOAT(0),  $                       ; 65- (deg)
      ap: FLOAT(0),  $                       ; 69- (deg)
      ma: FLOAT(0),  $                       ; 73- (deg)
      lam: FLOAT(0),  $                      ; 77- (deg.n)
                                             ;
      element_no: LONG(0),  $                ; 81- 
                                             ;
      spare3: BYTARR(11) }                   ; 85- Spare
   
   
   
Obs_WBSHXT = { Obs_WBSHXT_Rec,              $
      entry_type: BYTE(0),  $                ;  0- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ;  1- Major frame time (millisec of day)
      day: FIX(0),  $                        ;  5- Major frame day (since 1-Jan-79)
                                             ;
      DP_mode: BYTE(0),  $                   ;  7- DP Mode
      DP_rate: BYTE(0),  $                   ;  8- DP Rate
      Flare_Control: BYTE(0),  $             ;  9- Flare flag control (active triggers) W50
      Flare_Status: BYTE(0),  $              ; 10- Flare flag status
                                             ;
      HXT_Pow_stat: BYTE(0),  $              ; 11- HXT Power status                                  (W48 F32+1)
      HXT_sum_L: BYTE(0),  $                 ; 12- Low energy (cnts/sec)
                                             ;     Simple square root compression of original value
      HXT_sum_M1: BYTE(0),  $                ; 13- Medium-1 energy
                                             ;     Simple square root compression of original value
      HXT_sum_M2: BYTE(0),  $                ; 14- Medium-2 energy
                                             ;     Simple square root compression of original value
      HXT_sum_H: BYTE(0),  $                 ; 15- High energy
                                             ;     Simple square root compression of original value
      HXT_sigma_L: BYTE(0),  $               ; 16- Standard deviation of 16 "Fanbeam" subcollimator
                                             ;       counts (cnts/sec) - Low energy
                                             ;     Simple square root compression of original value
      HXT_HV_stat: BYTE(0),  $               ; 17- HXT HV Status                                     (W48 F32+17 (+2
                                             ;     Total for HXT = 7
                                             ;
      WBS_sxs1: BYTE(0),  $                  ; 18- SXS1 counts per sec.  Only SXS_PC12 are totaled
                                             ;     Simple square root compression of original value
      WBS_sxs2: BYTE(0),  $                  ; 19- SXS2 counts per sec.  Only SXS_PC21 are totaled
                                             ;     Simple square root compression of original value
      WBS_hxs: BYTE(0),  $                   ; 20- HXS counts per sec.  HXS_PC1 + HXS_PC2
                                             ;     Simple square root compression of original value
      WBS_grs1: BYTE(0),  $                  ; 21- GRS1 counts per sec.  GRS_PC11 + GRS_PC21
                                             ;     Simple square root compression of original value
      WBS_grs2: BYTE(0),  $                  ; 22- GRS2 counts per sec.  GRS_PC12 + GRS_PC22
                                             ;     Simple square root compression of original value
      WBS_rbmsc: BYTE(0),  $                 ; 23- RBMSC counts per sec.  PC1 + PC2
                                             ;     Simple square root compression of original value
      WBS_rbmsd: BYTE(0),  $                 ; 24- RBMSD counts per sec.
                                             ;     Simple square root compression of original value
      WBS_Pow_Stat: BYTE(0),  $              ; 25- 
      WBS_Stat: BYTE(0),  $                  ; 26- To be defined/expanded
                                             ;     Total for WBS = 9
                                             ;
      WhichInstru: BYTE(0),  $               ; 27- Which instruments are included and
                                             ;     how many records (data sets) were averaged
                                             ;     If the value is zero, there is no data
                                             ;       b0-3: HXT
                                             ;       b4-7: WBS
      spare: BYTARR(4) }                     ; 28- Spare
   
   
   
Obs_BCS_Obs = { Obs_BCS_Obs_Rec,              $
      entry_type: BYTE(0),  $                ;  0- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ;  1- Major frame time (millisec of day)
      day: FIX(0),  $                        ;  5- Major frame day (since 1-Jan-79)
                                             ;
      blockID: BYTE(0),  $                   ; 07- BCS Block ID                              
      SeqID: BYTE(0),  $                     ; 08- Observation Sequence ID                   
      ModeID: BYTE(0),  $                    ; 09- Mode ID (Grouper Plan)                    
      dgi: BYTE(0),  $                       ; 10- Data Gather Interval (125 msec units)     
      DP_Flags: BYTE(0),  $                  ; 11- DP Flags received by BCS                  
      BCS_Status: BYTE(0),  $                ; 12- BCS Status                        
                                             ;
      total_cnts: INTARR(4),  $              ; 13- Total counts in each channel for the mode
                                             ;
      All_cnts: BYTARR(4),  $                ; 21- BCS Counts for all events
                                             ;     Simple square root compression of original value
      Acc_cnts: BYTARR(4),  $                ; 25- BCS Accumulated counts 
                                             ;     Simple square root compression of original value
      Acc_interval: BYTE(0),  $              ; 29- Accumulation interval (sec)
                                             ;
      nAveraged: BYTE(0),  $                 ; 30- Number of spectra and DP major frames that
      spare: BYTARR(1) }                     ; 31- Spare
   
   
   
Obs_BCS_Status = { Obs_BCS_Status_Rec,              $
      entry_type: BYTE(0),  $                ; 00- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 01- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 05- Major frame day (since 1-Jan-79)
                                             ;
      hiVolt: BYTARR(2),  $                  ; 07- High Voltage trim value (0-7)
      HV_mon: BYTARR(2),  $                  ; 09- High voltage monitor (0-255)
      discrim: BYTARR(2,4),  $               ; 11- Low, high discriminator value (0-255)
      relays: BYTE(0),  $                    ; 19- Relays status
      status_2: BYTE(0),  $                  ; 20- Other status bits...
                                             ;
      spare: BYTARR(11) }                    ; 21- Spare
   
   
   
Obs_HXT_Status = { Obs_HXT_Status_Rec,              $
      entry_type: BYTE(0),  $                ; 00- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 01- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 05- Major frame day (since 1-Jan-79)
                                             ;
      HV_control: BYTARR(4),  $              ; 07-                                                           W49 F32
      HXA_gain_cont: BYTE(0),  $             ; 11- gain control commanded                                    W49 F32
                                             ;
      spare: BYTARR(20) }                    ; 12-
   
   
   
Obs_WBS_Status = { Obs_WBS_Status_Rec,              $
      entry_type: BYTE(0),  $                ; 00- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 01- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 05- Major frame day (since 1-Jan-79)
                                             ;
                                             ;
                                             ;
                                             ;
                                             ;
      spare: BYTARR(25) }                    ;  7-
   
   
   
Obs_SXT = { Obs_SXT_Rec,              $
      entry_type: BYTE(0),  $                ;  0- Observing Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 01- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 05- Major frame day (since 1-Jan-79)
                                             ;
      DP_mode: BYTE(0),  $                   ; 07- DP Mode
      DP_rate: BYTE(0),  $                   ; 08- DP Rate
                                             ;
      pfi_ffi: BYTE(0),  $                   ; 09- Image information 
      periph: BYTE(0),  $                    ; 10- Aspect/Shutter/Filter information
      ExpLevMode: BYTE(0),  $                ; 11- Exposure mode/level       
      imgparam: BYTE(0),  $                  ; 12- Image parameter information
                                             ;
      ObsRegion: BYTE(0),  $                 ; 13- Observing region Number
      seq_num: BYTE(0),  $                   ; 14- Entry in sequence table (1-13)    
      seq_tab_serno: FIX(0),  $              ; 15- Sequence table serial used
                                             ;
      shape_cmd: INTARR(2),  $               ; 17- Commanded image shape (nx/4 by ny/4)
      FOV_Center: INTARR(2),  $              ; 21- Pitch and yaw relative to the sun center
                                             ;     of the center of the SXT FOV (in arcsec)
                                             ;
      Img_Max: BYTE(0),  $                   ; 25- Maximum intensity
      Img_Avg: BYTE(0),  $                   ; 26- Average intensity of whole image
      Img_Dev: BYTE(0),  $                   ; 27- Average intensity around the max
      PercentD: BYTE(0),  $                  ; 28- Percentage of data present
      PercentOver: BYTE(0),  $               ; 29- Percentage of data over [N] counts
                                             ;
      Flare_Status: BYTE(0),  $              ; 30- Flare flag status
                                             ;
      spare: BYTARR(1) }                     ; 31- Spare bytes
   
   
   
  
  
end
