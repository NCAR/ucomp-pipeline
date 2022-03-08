pro evn_struct, Evn_Summary = Evn_Summary,  $
                     Evn_Common = Evn_Common,  $
                     Evn_PFI = Evn_PFI,  $
                     EVN_Version = EVN_Version
   
   
;+
;       NAME:
;               EVN_STRUCT
;       PURPOSE:
;               Define the following event log (EVN) specific database structures
;                       * EVN_Common_Rec
;                       * EVN_PFI_Rec
;
;       CALLING SEQUENCE:
;               EVN_STRUCT
;       HISTORY:
;               written by Mons Morrison, Fall 90.
;
;-
   
   
Evn_Summary = { Evn_Summary_Rec,              $
      time: LONG(0),  $                      ; 02- Time of beginning of Event (millisec of day)
      day: FIX(0),  $                        ; 06- Day of beginning of Event (since 1-Jan-79)
      dp_mode: BYTE(0),  $                   ;
      duration: LONG(0),  $                  ;   - The duration of the event in seconds
                                             ;
      event: FIX(0),  $                      ;   - The event that triggers the event to be written out
                                             ;               = 1 for New mode started
                                             ;               = 2 for more than 120 second gap between entries
                                             ;
                                             ;
      nMF: FIX(0),  $                        ;   - Number of major frames as derived from
                                             ;     the number of WBS/HXT observing log 
                                             ;     entries * 2
      nSXT_PFI: FIX(0),  $                   ;   - The number of SXT PFI images
      nSXT_FFI: FIX(0),  $                   ;   - The number of SXT FFI images
      nBCS: FIX(0),  $                       ;   - The number of BCS spectra
                                             ;
                                             ;
                                             ;      -------- Peak HXT values taken from OBS entry
      HXT_sum_L: BYTE(0),  $                 ; 12- Low energy (cnts/sec)
                                             ;     Simple square root compression of original value
      HXT_sum_M1: BYTE(0),  $                ; 13- Medium-1 energy
                                             ;     Simple square root compression of original value
      HXT_sum_M2: BYTE(0),  $                ; 14- Medium-2 energy
                                             ;     Simple square root compression of original value
      HXT_sum_H: BYTE(0),  $                 ; 15- High energy
                                             ;     Simple square root compression of original value
                                             ;
                                             ;      -------- Peak WBS values taken from OBS entry
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
                                             ;
                                             ;      -------- Peak BCS values taken from OBS entry
      total_cps: INTARR(4),  $               ; 13- Counts per second in the spectra dataset for each channel 
      All_cps: BYTARR(4),  $                 ; 21- BCS Counts for all events
                                             ;     Simple square root compression of original value
      Acc_cps: BYTARR(4),  $                 ; 25- BCS Accumulated counts
                                             ;     Simple square root compression of original value
                                             ;
                                             ;
                                             ;      -------- Field of View Center using SXT taken from OBS entry
      FOV_Center: INTARR(2),  $              ; 21- Pitch and yaw relative to the sun center
                                             ;     of the center of the SXT FOV (in arcsec)
                                             ;     This value is generally only useful for flare mode events since
                                             ;     Quiet mode has several observing regions and ARS can move around
      fov_change: BYTE(0),  $                ;   - Flag to signify the largest change between successive PFI locatio
                                             ;     in 30 arcsec increments
                                             ;               = 0 means no change
                                             ;               = 1 means it changed > 30 arcsec
                                             ;               = 2 means it changed > 60 arcsec
                                             ;               = 255 means there was no entry made (no PFI datasets 
                                             ;                 for that event)
                                             ;
                                             ;
      flag: BYTE(0),  $                      ;   - Flag information
                                             ;               = 1 false flare (SAA triggered)
                                             ;               = ...
                                             ;   - TODO - put in maximum count rates for WBS SXS1, ... HXT, ... BCS 
      spare: BYTARR(10) }                    ;
   
   
   
Evn_Common = { Evn_Common_Rec,              $
      entry_type: FIX(0),  $                 ; 00- Event Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 02- Major Frame time (millisec of day)
      day: FIX(0),  $                        ; 06- Major Frame day (since 1-Jan-79)
                                             ;
      Instru_on_off: BYTE(0),  $             ; 08- Instrument on/off 
                                             ;       0: HXT
                                             ;       1: SXT
                                             ;       2: BCS
                                             ;       3: WBS-SXS
                                             ;       4: WBS-HXS
                                             ;       5: WBS-GRS
                                             ;       6: WBS-RBM
      mode_rate: BYTE(0),  $                 ; 09- DP mode rate
                                             ;       0: Day/Night    (set = day)     
                                             ;       1: SAA          (set = SAA active)
                                             ;       2-3: DP Mode    (FL, QT, NT, other)
                                             ;       4-5: Telemetry Rate     (Lo, Med, Hi)
                                             ;       6: FFI Exposure (set = exposure taken)
      bcs_mode: BYTE(0),  $                  ; 10- BCS Mode Change (What is new mode?)
      flare_flag: BYTE(0),  $                ; 11- Flare flag
                                             ;       0: SXS          (set = triggered)
                                             ;       1: HXS          (set = triggered)
                                             ;       2: BCS          (set = triggered)
      CDROM_index: BYTARR(2),  $             ; 12- CD-ROM (or other) index number
      Telem_info: BYTE(0),  $                ; 14- Telemetry Coverage (Show transitions)
                                             ;       0: BDR Coverage (set = covered)
                                             ;       1: Real Time    (set = covered)
      FFI_Expos: BYTARR(4),  $               ; 15- Full width exposure paremeters
                                             ;       (0): Compression/resolution/... 
                                             ;       (1): Start Row
                                             ;       (2): End Row
                                             ;       (3): ??
      spare: BYTARR(13) }                    ; 19-
   
   
   
Evn_PFI = { Evn_PFI_Rec,              $
      entry_type: FIX(0),  $                 ; 00- Event Log Entry Type/Version
                                             ;
      time: LONG(0),  $                      ; 02- Major Frame time (millisec of day)
      day: FIX(0),  $                        ; 06- Major Frame day (since 1-Jan-79)
                                             ;
      FOV_Center: INTARR(2),  $              ; 08- Pitch and yaw relative to the sun center
                                             ;     of the center of the SXT FOV (in arcsec)
                                             ;
      NOAA_number: FIX(0),  $                ; 12- NOAA number
      num_images: INTARR(4),  $              ; 14- Summary of imagess
                                             ;       (1) = Number of images - thin filters
                                             ;       (2) = Number of images - medium filter
                                             ;       (3) = Number of images - thick filters
                                             ;       (4) = Number of images - optical filters
                                             ;
      resolution: BYTE(0),  $                ; 22- Highest resolution? or one entry per res?
      FOV: BYTE(0),  $                       ; 23- Field of view (largest/smallest/???)
                                             ;
      spare: BYTARR(8) }                     ; 24- Spare
   
   
   
EVN_Version = { EVN_Version_Rec,              $
      data : FIX('8011'x),  $                ;
                                             ; 00- The version number of the Roadmap
                                             ;     This value is not contained in the
                                             ;     roadmap structure to save space.  It is
                                             ;     saved in the "File Header Record"
                                             ;
                                             ;     This structure is not written to any files
      spare: BYTARR(14) }                    ;     (need for automatic conversion to IDL format)
   
   
   
  
  
end
