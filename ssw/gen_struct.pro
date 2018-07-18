pro gen_struct, Pointer = Pointer,  $
                     File_Header = File_Header,  $
                     QS_General1 = QS_General1,  $
                     GEN_Index = GEN_Index,  $
                     GEN2_Index = GEN2_Index,  $
                     MO_Disk_Map = MO_Disk_Map,  $
                     MO_Disk_Log = MO_Disk_Log
   
   
;+
;       NAME:
;               GEN_STRUCT
;       PURPOSE:
;               Define the following general database structures
;                       * Pointer_Rec              
;                       * File_Header_Rec          
;                       * QS_General1_Rec          
;                       * GEN_Index_rec            
;                       * GEN2_Index_rec            
;                       * MO_Disk_Map_Rec
;                       * MO_Disk_Log_Rec
;
;       CALLING SEQUENCE:
;               GEN_STRUCT
;       HISTORY:
;               written by Mons Morrison, Fall 90.
;                9-Mar-95 (MDM) - Added documentation comments 
;                               - (Compression of the data section)
;
;-
   
   
Pointer = { Pointer_Rec,              $
      Pointer_Version: FIX('1011'x),  $      ;
                                             ;  0- Pointer structure version
                                             ;
      type_integer: BYTE(0),  $              ;  2- Integer format convention 
                                             ;       1 = DEC (Digital) byte ordering (DEFAULT)
                                             ;       2 = Sun, MIPS, ... byte ordering
      type_real: BYTE(0),  $                 ;  3- Real format convention
                                             ;       1 = IEEE with DEC (Digital) byte ordering (DEFAULT)
                                             ;       2 = IEEE with Sun, MIPS, ... byte ordering
                                             ;       3 = DEC VAX with DEC (Digital) byte ordering
      file_structure: BYTE(0),  $            ;  4- (e.g., fixed record, stream of bytes)
                                             ;       1 = stream (IDL /BLOCK)
      VMS_rec_Size: LONG(0),  $              ;  5- Logical (physical on VMS) record length
                                             ;
                                             ;       -1 for the following pointers means no such section
                                             ;
      file_header: LONG(0),  $               ;  9- Pointer to File Header (Section 4.2)
                                             ;     Bytes from beginning of file
      qs_section: LONG(0),  $                ; 13- Pointer to Quasi-Static Index section
                                             ;     Bytes from beginning of file
      data_section: LONG(0),  $              ; 17- Pointer to Index and Data section
                                             ;     Bytes from beginning of file
      opt_section: LONG(0),  $               ; 21- Optional data section (BCS, WBS)
                                             ;     Bytes from beginning of file
      map_section: LONG(0),  $               ; 25- Pointer to Road Map section
                                             ;     Bytes from beginning of file
      TotBytes: LONG(0),  $                  ; 29- Total number of bytes in the file
                                             ;
      Header_Version : FIX('1021'x),  $      ;
                                             ; 33- Header structure version
      Roadmap_Version: FIX(0),  $            ; 35- Road map structure version
                                             ;     This value is defined in the
                                             ;     "Wrt___Map" Routines.
      Data_Version: FIX(0),  $               ; 37- Data structure version
                                             ;     This value is only used for
                                             ;     ATT and WBS files.
                                             ;
      itest: LONG(0),  $                     ; 39- Integer test pattern 
                                             ;       (value = '01020304'x = 16909060
      rtest: FLOAT(0),  $                    ; 43- Real test pattern 
                                             ;       (value = 1.234e+5)
      Spare: BYTARR(1) }                     ; 47- Spare
   
   
   
File_Header = { File_Header_Rec,              $
      fileVerNo: LONG(0),  $                 ; 00- File Structure version number
      progVerNo: LONG(0),  $                 ; 04- Program version number (v.vvv * 1000)
      st$progName: BYTARR(16),  $            ; 08- Name of creating program
      st$fileCreDate: BYTARR(11),  $         ; 24- file Creation Date (DD-MON-YYYY)
      st$fileCreTime: BYTARR(8),  $          ; 35- file Creation Time (HH:MM:SS)
      first_time: LONG(0),  $                ; 43- Time of first DATA SET in file 
      first_day: FIX(0),  $                  ; 47- Day of first DATA SET in file 
      last_time: LONG(0),  $                 ; 49- Time of last DATA SET in file 
      last_day: FIX(0),  $                   ; 53- Day of last  DATA SET in file 
      orb_st_time: LONG(0),  $               ; 55- Start time (millisec of day) of ORBIT
      orb_st_day: FIX(0),  $                 ; 59- Start day (since 1-Jan-79)
      orb_en_time: LONG(0),  $               ; 63- End time (millisec of day) or orbit
      orb_en_day: FIX(0),  $                 ; 81- End day (since 1-Jan-79)
                                             ;       (use ^^ times to compare to check with
                                             ;       quasi-static index times)
                                             ;
      nDataSets: LONG(0),  $                 ; 83- Number of data sets.  Each data set is:
                                             ;       For SDA this is a single image
                                             ;       For CBA,HDA,ATT this is a single major frame
                                             ;       For WDA this is two major frames
                                             ;       For BDA this is a single spectra
      maxSamps: LONG(0),  $                  ; 87- The maximum number of bins, samples, or 
                                             ;       pixels in all data sets in the file.
                                             ;
      ntot_qs: LONG(0),  $                   ; 91- Total number of quasi-static entries
      nrep_qs: LONG(0),  $                   ; 95- Number of repeated quasi-static entries
                                             ;       (should generally be zero, except when
                                             ;       a parameter is changed in orbit)
      ntot_opt: LONG(0),  $                  ; 99- Total number of optional entries
                                             ;     Not generally used since there is usually
                                             ;     a header structure at the beginning of the
                                             ;     optional data section.
                                             ;
      st$file_type: BYTARR(3),  $            ;103- Declaration of file type
                                             ;       The prefix of the file type so that 
                                             ;       the file can be identified internally.
                                             ;       Valid Options are:
                                             ;               BDA, SPR, SFR, HDA, WDA, ADA, CBA
      st$spacecraft: BYTARR(3),  $           ;106- Identification of the spacecraft from 
                                             ;       which the data originated 
                                             ;       Valid Options are:
                                             ;               SMM, P78, HIN, YOH (Yohkoh, Solar-A),
                                             ;               Gnd (Ground testing)
      st$instrument: BYTARR(3),  $           ;109- Identification of the instrument from 
                                             ;       which the data originated 
                                             ;       Valid Options are:
                                             ;               BCS, HXT, SXT, WBS, ATT
      st$machine: BYTARR(3),  $              ;112- The computer and/or operating system 
                                             ;       used to create the file 
                                             ;       Valid Options are:
                                             ;               ULX     - DEC Ultrix
                                             ;               VMS     - DEC VMS system
                                             ;               SGI     - Silicon Graphics Unix system
                                             ;               IBM
                                             ;               SUN
                                             ;               FAC     - Facom
                                             ;       Byte ordering and the storage of reals 
                                             ;       can be different on different computers.
      st$FileID: BYTARR(13),  $              ;115- File ID (to derive the file name)
                                             ;
      st$comment1: BYTARR(80),  $            ;128- comment field 1
      st$comment2: BYTARR(80),  $            ;208- comment field 2
                                             ;
      refVerNo: FIX(0),  $                   ;288- Reformatter program Version Number  (v.vvv * 1000)
      ref2VerNo: FIX(0),  $                  ;290- Reformatter #2 program Version Number  (v.vvv * 1000)
      progVerNo2: FIX(0),  $                 ;292- Secondary Program version number (v.vvv * 1000)
      st$progName2: BYTARR(16),  $           ;294- Secondary Name of creating program
                                             ;
      spare: BYTARR(26) }                    ;310- spare
   
   
   
QS_General1 = { QS_General1_Rec,              $
      entry_type : FIX('1011'x),  $          ;
                                             ; 00- Structure/Entry type
                                             ;
      st_time: LONG(0),  $                   ; 02- Start time (millisec of day) of valid data
      st_day: FIX(0),  $                     ; 06- Start day (since 1-Jan-79)
      en_time: LONG(0),  $                   ; 08- End time (millisec of day)
      en_day: FIX(0),  $                     ; 12- End day (since 1-Jan-79)
                                             ;
      scOffset: INTARR(3),  $                ; 14- Offset from S/C Boresight (arcsec)
                                             ;      (0) = Pitch; (1) = Yaw; (2) = Roll
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      hxtOffset: INTARR(3),  $               ; 20- Offset from HXT boresight (arcsec)
                                             ;      (0) = Pitch; (1) = Yaw; (2) = Roll
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      sxtOffset: INTARR(3),  $               ; 26- Offset from SXT boresight (arcsec)
                                             ;      (0) = Pitch; (1) = Yaw; (2) = Roll
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      bcsaOffset: INTARR(3),  $              ; 32- Offset from BCS-A boresight (arcsec)
                                             ;      (0) = Pitch; (1) = Yaw; (2) = Roll
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      bcsbOffset: INTARR(3),  $              ; 38- Offset from BCS-B boresight (arcsec)
                                             ;      (0) = Pitch; (1) = Yaw; (2) = Roll
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      offset_version: FIX(0),  $             ; 44- Offset solution version
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
      bAngle: LONG(0),  $                    ; 46- Solar B angle (arcsec)
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      dpf: BYTE(0),  $                       ; 50- Data presence flag
                                             ;       b0: Solar B angle is available
                                             ;       b1: Offset data is available
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
      time_sol_ver: FIX(0),  $               ; 51- Current algorithm and parameter version
                                             ;       used for converting between DP time 
                                             ;       and universal time
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      spare: BYTARR(11) }                    ; 53- Spare
   
   
   
GEN_Index = { GEN_Index_rec,              $
      index_version : FIX('1011'x),  $       ;
                                             ; 00- Index structure version                                   Ground 
                                             ;       AAAABBBB CCCCDDDD
                                             ;       AAAA = Instrument
                                             ;               1= General
                                             ;               2= BCS
                                             ;               3= SXT
                                             ;               4= HXT
                                             ;               5= WBS
                                             ;               6= ATT
                                             ;               7= CBA
                                             ;               8= Other
                                             ;               9= FEM
                                             ;               A= PNT
                                             ;       BBBB = Reserved for future use
                                             ;       CCCC = Separates different types of entries
                                             ;              (different QS types, ...)
                                             ;       DDDD = Version secondary number
                                             ;
      time: LONG(0),  $                      ; 02- Time (millisec of day)                                    Derived
                                             ;       (see "day" description for more details)
      day: FIX(0),  $                        ; 06- Day (since 1-Jan-79)                                      Derived
                                             ;     For BCS: This is the time that the data is
                                             ;               taken (not when it is read out of
                                             ;               the queue).  It uses the DP_Time
                                             ;               and the BCS clock value.
                                             ;     For HXT: This is major frame time.  There is a
                                             ;               four second offset buffer in the HXT
                                             ;               electronics.  The data for the dataset
                                             ;               is actually for 4 seconds BEFORE the
                                             ;               time listed in these fields.
                                             ;               NOTE: The definition for this fields might
                                             ;               be changed in Apr '92 to be the true time
                                             ;               of the data.  In that case, the read routines
                                             ;               will make a four second offset correction for
                                             ;               the old data files.
                                             ;     For SXT: This is major frame time when the 
                                             ;               image was commanded.  For the actual time
                                             ;               that the shutter opened, add the "exposure
                                             ;               latency" value (usually ~100 msec) to this time
                                             ;     For SXT/Gnd: This is the time when the file
                                             ;               was created
                                             ;     For WBS: This is major frame time
                                             ;
      dp_time: BYTARR(4),  $                 ; 08- DP time for the major frame
                                             ;     For BCS: This value is empty (see BCS_DP_Sync_Rec)
                                             ;               (0) = TIMER1                                    W50 F1
                                             ;                       LSB = "SFK" = 2048 sec
                                             ;                       (period of SFK clock = 4096)
                                             ;               (1) = TIMER2                                    W50 F0
                                             ;                       LSB = "SFC" = 8 sec
                                             ;                       (period of SFC clock = 16)
                                             ;               (2) = TIMER3                                    W51 F0
                                             ;                       LSB = "FA" = 0.03125 sec
                                             ;               (3) = FI (Frame Indicator)                      W03 F0
      DP_mode: BYTE(0),  $                   ; 12- DP Mode                                                   W50 F2
                                             ;     For BCS: This value is empty (see BCS_DP_Sync_Rec)
                                             ;       b0:4 =  xxx01001 (= 9) Flare mode
                                             ;               xxx01011 (=11) BCS-Out mode
                                             ;               xxx01100 (=12) Night mode
                                             ;               xxx01101 (=13) Quiet mode
      DP_rate: BYTE(0),  $                   ; 13- DP Rate                                                   W48 F15
                                             ;     For BCS: This value is empty (see BCS_DP_Sync_Rec)
                                             ;       b5:7 =  100xxxxx (=4) High rate
                                             ;               010xxxxx (=2) Medium rate
                                             ;               001xxxxx (=1) Low rate
      Flare_Control: BYTE(0),  $             ; 14- Flare flag control (active triggers)                      W50 F60
                                             ;     For BCS: This value is empty (see BCS_DP_Sync_Rec)
                                             ;       b4   = BCS triggering enabled
                                             ;       b3   = HXS-PC1 triggering enabled
                                             ;       b2   = SXS-PC triggering enabled
                                             ;       b0:1 = SXS sensors to allow triggering enabled
                                             ;               00 = SXS-PC11
                                             ;               01 = SXS-PC12 (default)
                                             ;               10 = SXS-PC21
                                             ;               11 = SXS-PC22
      Flare_Status: BYTARR(4),  $            ; 15- Flare flag status                                         W50 F16
                                             ;     For BCS: This value is empty (see BCS_DP_Sync_Rec)
                                             ;       b7   = Flare/RBM flag control (set = Auto)
                                             ;               Controls flare and RBM flags (auto/manual)
                                             ;       b6   = SXS detects a flare
                                             ;       b5   = HXS detects a flare
                                             ;       b4   = BCS detects a flare
                                             ;       b3   = RBM flag status (used for judging 
                                             ;             false or true Gamma burst (GBD))
                                             ;             (set= should cancel GBD flag)
                                             ;       b2   = RBM flag status for false or true flares
                                             ;             (set= should cancel flare flag)
                                             ;       b0:1 = Flare status
                                             ;               00: No flare
                                             ;               10: Normal flare
                                             ;               11: Great flare
                                             ;               01: BCS-MEM Dump Control
      RBM_Status: BYTE(0),  $                ; 19- Radiation Belt Montitor Status                            W50 F61
                                             ;       b7   = RBM status (set = on)
                                             ;               (RBM flag on allows for canceling flares)
                                             ;       b4:5 = Flare mode
                                             ;               11: Great Flare
                                             ;               10: Normal Flare
                                             ;               00: Quiet
                                             ;               01: BCS Memory mode out
      Telemetry_mode: BYTE(0),  $            ; 20- Telemetry mode                                            W51 F06
                                             ;       b0:3    = 0000 - Real time link
                                             ;               = 0001 - Recording playback
                                             ;               = 0101 - TMX Reproduce High
                                             ;               = 0110 - TMX Reproduce Low
                                             ;               = 0111 - TMS Reproduce High (no convolution)
                                             ;               = 1000 - TMS Reproduce low
                                             ;               = 1001 - TMS Reproduce High (Convolution)
      cal_status: BYTE(0),  $                ; 21- CAL status                                                W51 F55
                                             ;       b6 = HXT-CAL enable/disable (DP editing status)
                                             ;       b5 = HXT-CAL-DATA (overrides columns 6 and 7)
                                             ;       b4 = HXS-PH enable/disable
                                             ;       b3 = HXS-PH-CAL-DATA
                                             ;       b2 = GRS-CAL enable/diable
                                             ;       b1 = GRS-CAL-DATA
                                             ;     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                                             ;
      pntg_angle: LONARR(3),  $              ; 22- X,Y,Z euler angles in sun pointing coordinates            From Ma
                                             ;     (See ATT_STRUCT for full definition)
      pntg_Trace: BYTE(0),  $                ; 34- Information on how pointing was derived                   From Ma
                                             ;     and whether there is data present
                                             ;     (See ATT_STRUCT for full definition)
      pntg_jitter: BYTE(0),  $               ; 36- Magnitude of pointing change                              From Ma
                                             ;     (See ATT_STRUCT for full definition)
                                             ;
                                             ;     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      telemetry: BYTE(0),  $                 ; 38- Telemetry source information                              W7 in 1
                                             ;       b0:3 = Ground Station 
                                             ;               0 = KSC Real time data
                                             ;               1 = KSC playback data
                                             ;               5 = DSN - Goldstone playback data
                                             ;               7 = DSN - Canberra playback data
                                             ;               9 = DSN - Madrid playback data
                                             ;               15 = Ground based (test data)   
                                             ;       b4:7 = Bit rate
                                             ;               0 = low
                                             ;               1 = medium
                                             ;               2 = high
      sirius: BYTARR(5),  $                  ; 39- Sirius data base information ??                           Ground 
                                             ;       TODO ?? - What info here? - path?
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
                                             ;
                                             ;     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      data_quality: BYTE(0),  $              ; 44- Data quality                                              Ground 
                                             ;               1 = good
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      nmissSamps: LONG(0),  $                ; 45- Number of missing bytes (due to telemetry                 Ground 
                                             ;     drop outs - minor or major frames)
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
      StartSamp: LONG(0),  $                 ; 45- Starting sample number of good data                       Ground 
                                             ;       (zero if there are no dropouts)
                                             ;       [NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
                                             ;     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      data_word_type: BYTE(0),  $            ; 49- Data word type (byte, integer*2, real...)                 Ground 
                                             ;       b0:3 = Data word type
                                             ;               0 = byte
                                             ;               1 = integer*2
                                             ;               2 = integer*4
                                             ;               3 = real*4
                                             ;       b4   = Set if data is compressed
                                             ;       b5-6 = SPARE
                                             ;       b7   = data section has been Unix compressed 
      nIndexStruct: FIX(0),  $               ; 50- Number of "extra" index structures following
                                             ;     the general index structure
                                             ;     (for additional "ground" structures,
                                             ;     processing information structures, ...)
      nIndexByte: FIX(0),  $                 ; 52- Number of bytes in the index records
      nDataByte: LONG(0),  $                 ; 54- Number of byte in the data section
                                             ;
      SXT_Pow_stat: BYTE(0),  $              ; 58- Power Status (0=off, 1=on)                                W48  F2
                                             ;       b7 = 5 Volts
                                             ;       b6 = 28 Volts
                                             ;       b5 = Filter Wheel
                                             ;       b4 = Shutter / Aspect Controller
                                             ;       b3 = Micro A Select
                                             ;       b2 = Micro B Select
                                             ;       b1 = Camera
                                             ;       b0 = Thermoelectric Cooler (TEC)
      bcs_pow_stat: BYTE(0),  $              ; 59- BCS Power status                                          W112 F3
                                             ;       b0 = Calibibration-B (set=enabled)
                                             ;       b1 = HVB logical flag (set=enabled)
                                             ;       b2 = HVB power (set=on)
                                             ;       b3 = Spectrometer B (set=on)
                                             ;       b4 = Calibibration-A (set=enabled)
                                             ;       b5 = HVA logical flag (set=enabled)
                                             ;       b6 = HVA power (set=on)
                                             ;       b7 = Spectrometer A (set=on)
      hxt_Pow_stat: BYTE(0),  $              ; 60- HXT Power status                                          W48 F32
                                             ;       b7 = HXT1 (electronics for 00 to 31)
                                             ;       b6 = HXT2 (electronics for 32 to 63)
                                             ;       b5 = OS memory status 
                                             ;       b4 = HXA on/off
                                             ;       b3 = HXA cal
                                             ;       b2 = HXT cal
                                             ;       b1 = HV reduction fuction on/off (enable SAA HV on/off)
                                             ;            Usually HV is 900 V, reduced to ~0 V when on
                                             ;       b0 = HV enable (double command safety)
                                             ;            HV cannot go on until this is enabled
      wbs_pow_stat: BYTE(0),  $              ; 61- Power status                                              W48 F32
                                             ;       b7 = WBS HV enable/disable
                                             ;       b6 = WBS on/off (set=on)
                                             ;       b5 = WBS-A on/off (set=on)
                                             ;       b4 = SXS-HV on/off (set=on)
                                             ;       b3 = HXS-HV on/off (set=on)
                                             ;       b2 = GRS-HV1 on/off (set=on)
                                             ;       b1 = GRS-HV2 on/off (set=on)
                                             ;       b0 = RBM-HV on/off (set=on)
      SXT_Control: BYTE(0),  $               ; 62- SXT Control Status                                        W114 F3
                                             ;       b7   = Power control mode (1=auto, 0=manual)
                                             ;       b6   = SXT control mode (1=auto, 0=manual)
                                             ;       b2:3 = SXT day/night mode
                                             ;               00 = SXT day mode
                                             ;               01 = SXT evening mode
                                             ;               10 = SXT night mode
                                             ;               11 = SXT morning mode
                                             ;       b1   = SXTE-U hard reset (1=executed)
                                             ;       b0   = SXTE-U soft reset (1=executed)
      spare1: BYTARR(15) }                   ; 63- Spare Bytes
   
   
   
GEN2_Index = { GEN2_Index_rec,              $
      index_version : FIX('1021'x),  $       ;
                                             ; 00- Index structure version                                   Ground 
                                             ;       (see definition in GEN_Index_Rec)
      spare1: BYTARR(2),  $                  ; 02 -Padding byte
                                             ;
      time: LONG(0),  $                      ; 04- Time (millisec of day)                                    Derived
                                             ;       (see definition in GEN_Index_Rec)
      day: FIX(0),  $                        ; 08- Day (since 1-Jan-79)                                      Derived
                                             ;       (see definition in GEN_Index_Rec)
                                             ;
      DP_mode: BYTE(0),  $                   ; 10- DP Mode                                                   W50 F2
                                             ;       (see definition in GEN_Index_Rec)
      DP_rate: BYTE(0),  $                   ; 11- DP Rate                                                   W48 F15
                                             ;       (see definition in GEN_Index_Rec)
                                             ;
                                             ;     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      data_word_type: BYTE(0),  $            ; 12- Data word type (byte, integer*2, real...)                 Ground 
                                             ;       (see definition in GEN_Index_Rec)
      spare2: BYTARR(3),  $                  ; 13 -Padding byte
      nIndexByte: FIX(0),  $                 ; 16- Number of bytes in the index records
      spare3: BYTARR(2),  $                  ; 18 -Padding byte
      nDataByte: LONG(0),  $                 ; 20- Number of byte in the data section
                                             ;
                                             ;
      spare: BYTARR(8) }                     ; 24- Spare Bytes
   
   
   
MO_Disk_Map = { MO_Disk_Map_Rec,              $
      time: LONG(0),  $                      ; 00- Time of first data available (millisec of day)
      day: FIX(0),  $                        ; 04- Day of first data available (since 1-Jan-79)
                                             ;
      mo_disk: FIX(0),  $                    ; 06- MO Disk number (000)
      st$side: BYTARR(1),  $                 ; 08- MO disk side ('A' or 'B')
      st$label: BYTARR(12),  $               ; 09- FileID of label (eg: '910915.0924a')
      st$week: BYTARR(6),  $                 ; 21- Week ('91_41b')
                                             ;
      st$first_fid: BYTARR(11),  $           ; 27- The first FileID on the side of MO disk
      st$last_fid: BYTARR(11),  $            ; 38- The last FileID on the side of MO disk
      nfid: FIX(0),  $                       ; 49- The number of FIDS in that span
                                             ;
      spare: BYTARR(13) }                    ; 51- Spare Bytes
   
   
   
MO_Disk_Log = { MO_Disk_Log_Rec,              $
      time: LONG(0),  $                      ; 00- Time that the MO disk creation was finished
      day: FIX(0),  $                        ; 04- Day that the MO disk creation was finished
                                             ;
      refVerNo: FIX(0),  $                   ;  6- Reformatter program Version Number  (v.vvv * 1000)
      st$operator: BYTARR(10),  $            ;  8- Name of person MO disk was made by
                                             ;
      spare: BYTARR(6) }                     ; 18- Spare Bytes
   
   
   
  
  
end
