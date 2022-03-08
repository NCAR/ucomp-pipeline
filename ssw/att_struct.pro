pro att_struct, ATT_Data = ATT_Data,  $
                     ATT_Pntg_Save = ATT_Pntg_Save,  $
                     HXA_Scan = HXA_Scan,  $
                     HXA_Scan_Head = HXA_Scan_Head,  $
                     ATT_Roadmap = ATT_Roadmap,  $
                     ATT_Version = ATT_Version,  $
                     ATR_Summary = ATR_Summary,  $
                     ATT_Summary = ATT_Summary
   
   
;+
;       NAME:
;               ATT_STRUCT
;       PURPOSE:
;               Define the following ATT specific database structures
;                       * ATT_Data_Rec
;                       * ATT_Roadmap_Rec
;                       * HXA_Scan_Head_Rec
;                       * HXA_Scan_Rec
;
;       CALLING SEQUENCE:
;               ATT_STRUCT
;       HISTORY:
;               written by Mons Morrison, Fall 90.
;               22-Sep-1994 (SLF) - Documentation only (STATUS2 field)
;                7-Mar-1995 (MDM) - Documentation only (STATUS1 field)
;
;-
   
   
ATT_Data = { ATT_Data_Rec,              $
                                             ;----- Inertial Reference Unit (IRU) ----------------------
      iru_pow_stat: BYTARR(2),  $            ;  0- IRU Power Status                                          W48 F32
                                             ;       b7 = ??
                                             ;       b6 = Loop??
                                             ;       b5 = X Motor on/off
                                             ;       b4 = Y Motor on/off
                                             ;       b3 = Z Motor on/off
                                             ;       b2 = S Motor on/off
                                             ;       b1 = ??
                                             ;       b0 = 
      iru_LM: BYTARR(5,2),  $                ;  2- IRU ??                                                    W112 F3
                                             ;    (i,j)  j=two values per major frame
                                             ;       (0,*) = X voltage?? (0-3 V)
                                             ;       (1,*) = Y voltage?? (0-3 V)
                                             ;       (2,*) = Z voltage?? (0-3 V)
                                             ;       (3,*) = S voltage?? (0-3 V)
                                             ;       (4,*) = MC??
      iru_temp: BYTE(0),  $                  ; 12- IRU Temperature                                           W32 F52
      iru: LONARR(3,8),  $                   ;  0- X roll?                                                   W17,W18
                                             ;     Y roll?                                                   W17,W18
                                             ;     Z roll?                                                   W17,W18
                                             ;    (i,j)  i=0 is X, i=1 is Y, i=2 is Z
                                             ;           j=eight values per major frame
                                             ;  W17 is high 8 bits of 24 bit value
                                             ;  W18 is middle 8 bits of 24 bit value
                                             ;  W19 is low 8 bits of 24 bit value
                                             ;
                                             ;   24-bit value is the roll/pointing?
                                             ;       LSB (1 DN) = 0.08 arcsec (one "pulse")
                                             ;
                                             ;----- Geomagnetic Attitude Sensor (GAS) ----------------------
      gas_pow_stat: BYTE(0),  $              ; ??- GAS Power Status                                          W48 F24
                                             ;       b2 = GAS on/off
                                             ;       b1 = GAS Sensor SA/SB (set = SB)
      gas_A_HK: BYTE(0),  $                  ; ??- GAS-A Analog house keeping                                W32 F36
      gas_E_HK: BYTE(0),  $                  ; ??- GAS-A Analog house keeping                                W32 F54
      gas: BYTARR(3,4),  $                   ; 96- X position                                                W81 F16
                                             ;     Y position                                                W82 F16
                                             ;     Z position                                                W83 F16
                                             ;    (i,j)  i=0 is X, i=1 is Y
                                             ;           j=four values per major frame
                                             ;   8-bit value is the ?? position 
                                             ;   between 0 and 512 pixels
                                             ;       LSB (1 DN) = .0390625 volts (10,000 nT/volt)
                                             ;
                                             ;----- Two-Dimensional Fine Sun Sensor (TFSS) ----------------
      tfss_pow_stat: BYTE(0),  $             ;???- TFSS Power status                                         W48 F24
                                             ;       b5 = TFSS on/off
                                             ;       b4 = TFSS Cal??
      tfss_v: BYTARR(2),  $                  ;   - TFSS voltages??                                           W32 F13
      tfss_temp: BYTE(0),  $                 ;   - TFSS Temperature                                          W32 F55
      TFSS: INTARR(2,4),  $                  ;108-X Position                                                 W82,W83
                                             ;    Y Position                                                 W82,W83
                                             ;    (i,j)  i=0 is X, i=1 is Y
                                             ;           j=four values per major frame
                                             ;  W82 is high 8 bits of 12 bit value
                                             ;  W83 b4:7 = low 8 bits of 12 bit value
                                             ;   12-bit value is the ?? position 
                                             ;   between 0 and 512 pixels
                                             ;       LSB (1 DN) = 0.00054 deg
                                             ;  W83
                                             ;       b3 = x/y sun presence        (1=on, 0=off)
                                             ;       b2 = x/y quality flag        (1=on, 0=off)
                                             ;
                                             ;----- Non-Spin Type Attitude Sensor (NSAS) -----------------
      nsas_pow_stat: BYTE(0),  $             ;???- NSAS Power status                                         W48 F24
                                             ;       b7 = NSAS on/off
                                             ;       b6 = NSAS Cal??
      nsas_v: BYTARR(2),  $                  ;   - NSAS voltages??                                           W32 F15
      nsas_temp: BYTE(0),  $                 ;   - NSAS Temperature                                          W32 F56
      nsas: INTARR(2,4),  $                  ;124- NSAS X address?                                           W82,W83
                                             ;     NSAS Y address?                                           W82,W83
                                             ;     (i,j)  i=0 is X, i=1 is Y
                                             ;           j=four values per major frame
                                             ;  W82 is high 8 bits of 12 bit value
                                             ;  W83 b4:7 = low 8 bits of 12 bit value
                                             ;   12-bit value is the ?? position 
                                             ;   between 0 and 512 pixels
                                             ;       LSB (1 DN) = 0.5 pixels)
                                             ;       x=0, y=0 ==> 0.025 deg
                                             ;  W83
                                             ;       b3 = x/y sun presence        (1=on, 0=off)
                                             ;       b2 = x/y edge flag           (1=on, 0=off)
                                             ;       b1 = x/y upper discriminator (1=on, 0=off)
                                             ;       b0 = x/y lower discriminator (1=on, 0=off)
                                             ;
                                             ;----- Star Tracker (STT) ----------------------
      stt_pow_stat: BYTE(0),  $              ;???-STT power status                                           W48 F2
                                             ;       b7 = CPU1 on/off
                                             ;       b6 = CPU2 on/off
                                             ;       b5 = 
                                             ;       b4 = 
                                             ;       b3 = 
                                             ;       b2 = 
                                             ;       b1 = 
                                             ;       b0 = 
      stt_stat: BYTARR(3),  $                ;?? - STT Status                                                W48 F18
                                             ;       b7 = 
                                             ;       b6 = 
                                             ;       b5 = 
                                             ;       b4 = 
                                             ;       b3 = 
                                             ;       b2 = 
                                             ;       b1 = 
                                             ;       b0 = 
      stt_v: BYTE(0),  $                     ;?? - STT Voltages                                              
                                             ;       For FI = 0 = STT CCD                                    W32 F17
                                             ;       For FI = 2 = STT REG                                    W32 F17
      stt_temp: BYTARR(2),  $                ;?? - STT Temperatures                                          W32 F56
                                             ;
      stt_H_Pos: INTARR(2),  $               ;140-STT star position (H) - horizontal?                        W82,W83
                                             ;    (j) j=two values per major frame
                                             ;   16-bit value is the star pixel position ?
                                             ;   between 0 and 512 pixels
                                             ;       LSB (1 DN) = 0.007812 pixels
      stt_V_Pos: INTARR(2),  $               ;144-STT star position (V) - vertical?                          W82,W83
                                             ;    (j) j=two values per major frame
      stt_int: INTARR(2),  $                 ;148-STT star intensity                                         W82,W83
                                             ;    (j) j=two values per major frame
      stt_alarm: INTARR(2),  $               ;152-STT alarm signal                                           W82,W83
                                             ;    (j) j=two values per major frame
                                             ;
                                             ;----- HXT 2-D Aspect Sensor ----------------------
      hxa_pow_stat: BYTE(0),  $              ; ??- HXA Power Status                                          W48 F1
                                             ;       b4 = HXA on/off
                                             ;       b3 = HXA cal
      hxa_addr: INTARR(32,2),  $             ;156- Address of positions below discriminator                  W33,W34
                                             ;     (limbs and fiducial)
                                             ;    (j,i) j=32 addresses per major frame
                                             ;          i=0 is two sets of addresses per major frame
                                             ;       The variable "hxa_xnum" tells how many x adresses
                                             ;       there are in "hxa_addr" and "hxa_ynum" tells how
                                             ;       many y addresses.  The y addresses need to have
                                             ;       2048 subtracted from the value.
      hxa_xnum: BYTARR(2),  $                ;284- Number of positions along X below discrim                 W49 F32
                                             ;          Two sets per major frame
      hxa_ynum: BYTARR(2),  $                ;286- Number of positions along Y below discrim                 W49 F32
                                             ;          Two sets per major frame
      hxa_gain: BYTARR(2),  $                ;288- Gain for HXA                                              W49 F32
                                             ;          Two sets per major frame
      HXA_gain_cont: BYTARR(2),  $           ; 80- Gain control commanded                                    W49 F32
                                             ;       Hopefully not changed 
                                             ;       TODO - what is this - same Frame/Word as "hxa_xnum"
                                             ;
                                             ;----- S/C Processed pointing info ----------------------
      sc_pntg: LONARR(3,2),  $               ;290- X,Y,Z euler angles in sun pointing coordinates
                                             ;   - X Offset from sun center                                  W17,W18
                                             ;     Y offset from sun center                                  W17,W18
                                             ;     Z roll from solar-north                                   W17,W18
                                             ;    (i,j)  i=0 is X, i=1 is Y, i=2 is Z
                                             ;           j=two values per major frame
                                             ;  W17 is high 8 bits of 24 bit value
                                             ;  W18 is middle 8 bits of 24 bit value
                                             ;  W19 is low 8 bits of 24 bit value
                                             ;       LSB (1 DN) = 0.1 arcsec
                                             ;
                                             ;----- Ground Processed pointing info ----------------------
      pntg_angle: LONARR(3),  $              ;290- X,Y,Z euler angles in sun pointing coordinates            From Ma
                                             ;     1 DN = 0.1 arcsec
      pntg_dev: LONARR(3),  $                ;302- X,Y,Z standard deviation of attitude                      From Ma
                                             ;     determination errors
                                             ;     1 DN = .01"
      pntg_motion: LONARR(3),  $             ;314- X,Y,Z estimated drift rates                               From Ma
                                             ;     1 DN = 1.0"/hour
      pntg_status: LONG(0),  $               ;326- Status                                                    From Ma
                                             ;       b15 = TFSS  0=not used, 1=used
                                             ;       b14 = NSAS  0=not used, 1=used
                                             ;       b13 = STT   0=not used, 1=used
                                             ;       b12 = GAS   0=not used, 1=used
                                             ;       b11 = IRU   0=not used, 1=used
                                             ;       b10 = ACP   0=not used, 1=used
                                             ;       b9  = Spec  0=coarse, 1=fine
                                             ;       b8  =       0=propagation, 1=renewal
                                             ;       b7  =       0=forward, 1=backward
                                             ;       b6  = sun presence 0=night, 1=day
                                             ;       b5  = earth occultation 0=occul, 1=not occul
      pntg_Trace: BYTE(0),  $                ; 30- Information on how pointing was derived                   Ground 
                                             ;     and whether there is data present
                                             ;       0 = No data present
                                             ;       1 = Original Technique used 20-Oct-91 to ??
                                             ;           The data in "pntg_angle" is the average of
                                             ;           8 raw IRU values (there are 8 values per
                                             ;           major frame).  If the time of the data
                                             ;           does not match the time of the IRU data
                                             ;           within 5 minutes, then no data is present.
      pntg_jitter: BYTE(0),  $               ; 32- Magnitude of pointing change over ??sec                   Derived
                                             ;       in ??
                                             ;       scaled - TODO
                                             ;
      spare: BYTARR(10) }                    ;330-
   
   
   
ATT_Pntg_Save = { ATT_Pntg_Save_Rec,              $
                                             ;This structure is not written to the reformatted data files.
                                             ;It is simply used to store the processed pointing information
                                             ;which will be inserted into the "Gen_Index" fields
      time: LONG(0),  $                      ;   - Major frame time (millisec of day)
      day: FIX(0),  $                        ;   - Major frame day (since 1-Jan-79)
      pntg_angle: LONARR(3),  $              ;   - X,Y,Z euler angles in sun pointing coordinates            From Ma
      pntg_Trace: BYTE(0),  $                ;   - Information on how pointing was derived                   Ground 
                                             ;     and whether there is data present
      pntg_jitter: BYTE(0) }                 ;   - Magnitude of pointing change over ??sec                   Derived
   
   
   
HXA_Scan = { HXA_Scan_Rec,              $
      time: LONG(0),  $                      ; 04- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 08- Major frame day (since 1-Jan-79)
                                             ;
      x_scan_int: BYTARR(2048),  $           ;   - X scan intensity
      y_scan_int: BYTARR(2048),  $           ;   - Y scan intensity
      nPoScan: FIX(0),  $                    ;   - Number of points in the scan (2048 if full)
                                             ;
      spare: BYTARR(8) }                     ;
   
   
   
HXA_Scan_Head = { HXA_Scan_Head_Rec,              $
      index_version : FIX('6011'x),  $       ;
                                             ; 00- Index structure version
                                             ;
      nEntries: FIX(0),  $                   ;  2- Number of HXA scans to follow
                                             ;
      spare: BYTARR(12) }                    ;  4- Spares
   
   
   
ATT_Roadmap = { ATT_Roadmap_Rec,              $
                                             ;     For a full description of the fields,
                                             ;     look at the Index_Rec definition
                                             ;
      ByteSkip: LONG(0),  $                  ; 00- Offset in bytes from the beginning of
                                             ;     of the data file for the beginning
                                             ;     of the data set index structure.
                                             ;
      time: LONG(0),  $                      ; 04- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 08- Major frame day (since 1-Jan-79)
                                             ;
      DP_mode: BYTE(0),  $                   ; 10- DP Mode
      DP_rate: BYTE(0),  $                   ; 11- DP Rate
                                             ;
      Flare_Control: BYTE(0),  $             ; 12- Flare flag control (active triggers) 
      Flare_Status: BYTE(0),  $              ; 13- Flare flag status                 
      RBM_Status: BYTE(0),  $                ; 14- Radiation Belt Montitor Status    
      Telemetry_mode: BYTE(0),  $            ; 15- Telemetry mode                    
      cal_status: BYTE(0),  $                ; 16- CAL status                        
                                             ;
      SXT_Pow_stat: BYTE(0),  $              ; 17- SXT Power Status
      bcs_pow_stat: BYTE(0),  $              ; 18- BCS Power status
      hxt_Pow_stat: BYTE(0),  $              ; 19- HXT Power status
      wbs_pow_stat: BYTE(0),  $              ; 20- WBS Power status
      SXT_Control: BYTE(0),  $               ; 21- SXT Control Status
                                             ;
      telemetry: BYTE(0),  $                 ; 22- Telemetry source information 
                                             ;
      spare: BYTARR(9) }                     ; 23-
   
   
   
ATT_Version = { ATT_Version_Rec,              $
      roadmap : FIX('60F1'x),  $             ;
                                             ; 00- The version number of the Roadmap
                                             ;     This value is not contained in the
                                             ;     roadmap structure to save space.  It is
                                             ;     saved in the "File Header Record"
      data : FIX('60E2'x),  $                ; 02- Data section version number
                                             ;
                                             ;     This structure is not written to any files
      spare: BYTARR(12) }                    ;     (need for automatic conversion to IDL format)
   
   
   
ATR_Summary = { ATR_Summary_Rec,              $
                                             ;NOTE: See ATT_STRUCT for details on definitions.
                                             ;
      time: LONG(0),  $                      ;  0- Major frame time (millisec of day)
      day: FIX(0),  $                        ;  4- Major frame day (since 1-Jan-79)
                                             ;
      iru: LONARR(3),  $                     ;  8- Inertial Reference Unit
      TFSS: INTARR(2),  $                    ; 20- Two-Dimensional Fine Sun Sensor
      hxa: INTARR(4),  $                     ; 24- HXT Aspect sensor
                                             ;       (0) = low address for x
                                             ;       (1) = high address for x
                                             ;       (2) = low address for y
                                             ;       (3) = high address for y
                                             ;
      DP_mode: BYTE(0),  $                   ;  6- DP Mode
      DP_rate: BYTE(0) }                     ;  7- DP Rate 
   
   
   
ATT_Summary = { ATT_Summary_Rec,              $
      time: LONG(0),  $                      ;  0- Major frame time (millisec of day)
      day: FIX(0),  $                        ;  4- Major frame day (since 1-Jan-79)
                                             ;
      DP_mode: BYTE(0),  $                   ;  6- DP Mode
      DP_rate: BYTE(0),  $                   ;  7- DP Rate 
                                             ;
      pnt: LONARR(3),  $                     ;  8- S/C processed pointing.
                                             ;     The Units are SXT (FRE) pixels and the value FRE = 0.01*pnt is th
                                             ;     location of the x-ray center of the sun.
                                             ;       
                                             ;       (0) = E/W direction (E has smaller values)
                                             ;       (1) = N/S direction (S has smaller values)
                                             ;       (2) = Roll in 0.1 arcsecond units - Negative values are S/C rot
                                             ;             counter-clockwise relative to solar north
                                             ;
                                             ;               E/W and N/S Used ??? program which takes HXA and IRU to
                                             ;               pointing value.  The program corrects for:
                                             ;                       Orbital phase Shift between SXT and HXA
                                             ;                       Mission (non-seasonal) shift between SXT and HX
                                             ;                       ??
                                             ;
                                             ;               Roll uses the mainframe derived ADS (Attitude Determina
                                             ;               results.
      status1: BYTE(0),  $                   ; 20- Information on the HXA data quality
                                             ;       = 1: plain S/C commanded value used, no dejittering with IRU.
                                             ;       = 2: S/C commanded value dejittered with IRU.
                                             ;       = 4: HXA value dejittered with IRU.  Standard result, good.
      status2: BYTE(0),  $                   ; 21- Information on Program/Algorithms used
                                             ;     b7:4  Spare
                                             ;     b3:0  Reserved for fix_old_att enabled 21-Sep-94
                                             ;           to correct for a systematic error in the adjustment for 
                                             ;           orbital variations.  It was on the order of 15 arcsec for 1
                                             ;        b3    Correction Applied flag.
                                             ;        b2:0  Correction Algorithm Version#  
                                             ;    
      ads: BYTE(0),  $                       ; 22- b0 - Set if ADS results were inserted into the record
                                             ;
      spare: BYTARR(1) }                     ; 23-
   
   
   
  
  
end
