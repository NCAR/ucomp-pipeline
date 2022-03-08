pro sxt_struct, SXT_QS_Instr = SXT_3011_QS_Instr,  $
                     SXT_QS_Conv = SXT_3021_QS_Conv,  $
                     SXT_Index = SXT_3013_Index,  $
                     SXT_Gnd_Idx = SXT_3021_Gnd_Idx,  $
                     SXT_Proc_Idx = SXT_3032_Proc_Idx,  $
                     SXT_RoadMap = SXT_RoadMap,  $
                     SXT_Version = SXT_Version,  $
                     SXT_SumLog = SXT_3041_SumLog,  $
                     SXT_RAMDump = SXT_3051_RAMDump,  $
                     SXT_DarkLog = SXT_3061_DarkLog,  $
                     SXT_EnginLog = SXT_3071_EnginLog,  $
                     SXT_OptTel = SXT_3081_OptTel,  $
                     SXT_XrCen = SXT_30B1_XrCen,  $
                     SXT_XrayLog = SXT_3091_XrayLog,  $
                     SXT_Xray2Log = SXT_3092_Xray2Log,  $
                     SXL_RoadMap = SXL_39F1_RoadMap,  $
                     SXG_SXTGOES = SXG_39F1_SXTGOES,  $
                     SXT_Leak = SXT_30A1_Leak
   
   
;+
;       NAME:
;               SXT_STRUCT
;       PURPOSE:
;               Define the following SXT specific database structures
;                       * SXT_QS_Instr_Rec         
;                       * SXT_QS_Conv_Rec          
;                       * SXT_Index_Rec            
;                       * SXT_Gnd_Idx_Rec          
;                       * SXT_Proc_Idx_Rec         
;                       * SXT_RoadMap_Rec          
;
;                       * SXT_SumLog_Rec
;                       * SXT_RAMDump_Rec
;                       * SXT_DarkLog_Rec
;                       * SXT_EnginLog_Rec
;                       * SXT_OptTel_Rec
;                       * SXT_Leak_Rec
;
;       CALLING SEQUENCE:
;               SXT_STRUCT
;       HISTORY:
;               written by Mons Morrison, Fall 90.
;               15-Mar-93 (MDM) - Modified to have the structure version
;                                 number in the structure name
;               28-Feb-93 (MDM) - Changed the label information for the
;                                 temperature house keeping sensors
;
;-
   
   
SXT_3011_QS_Instr = { SXT_3011_QS_Instr_Rec,              $
                                             ;       NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
      entry_type : FIX('3011'x),  $          ;
                                             ; 00- Structure/Entry type
                                             ;
      st_time: LONG(0),  $                   ; 02- Start time (millisec of day) entries are valid
      st_day: FIX(0),  $                     ; 06- Start day (since 1-Jan-79)
      en_time: LONG(0),  $                   ; 08- End time (millisec of day)
      en_day: FIX(0),  $                     ; 12- End day (since 1-Jan-79)
                                             ;
      gain_const: FIX(0),  $                 ; 14- Camera gain constant (e/DN*100)
                                             ;
      st$DC_FileID: BYTARR(11),  $           ; 16- Suggested dark current file name to be used
                                             ;
      solution_ver: FIX(0),  $               ; 27- Solution version
                                             ;
      spare: BYTARR(3) }                     ; 29-
   
   
   
SXT_3021_QS_Conv = { SXT_3021_QS_Conv_Rec,              $
                                             ;       NOT IMPLEMENTED AS OF 25-Mar-92]
                                             ;
      entry_type : FIX('3021'x),  $          ;
                                             ; 00- Structure/Entry type
                                             ;
      st_time: LONG(0),  $                   ; 02- Start time (millisec of day) entries are valid
      st_day: FIX(0),  $                     ; 06- Start day (since 1-Jan-79)
      en_time: LONG(0),  $                   ; 08- End time (millisec of day)
      en_day: FIX(0),  $                     ; 12- End day (since 1-Jan-79)
                                             ;
      temp_conv: INTARR(10,2),  $            ; 14- Conversion for temperature in 0.01 deg.
                                             ;
      solution_ver: FIX(0),  $               ; 54- Solution version
                                             ;
      spare: BYTARR(8) }                     ; 56-
   
   
   
SXT_3013_Index = { SXT_3013_Index_Rec,              $
      index_version : FIX('3013'x),  $       ;
                                             ;  0- Index structure version                                   Ground 
                                             ;     (See GEN_INDEX for explanation)
                                             ;
      pfi_ffi: BYTE(0),  $                   ;  2- Image information                                         
                                             ;       b0:2 = Image type
                                             ;            0 = PFI ("raw" PFI strips - not assembled)         Derived
                                             ;            1 = FFI
                                             ;            2 = PFI (assembled ORs)
                                             ;            3 = FFI - Patrol image buffer dump
                                             ;               (b0=0 is PFI, b0=1 is FFI)
                                             ;       b3   = For FFI 0=BLS off, 1=BLS on                      W114 F0
                                             ;       b4:7 = For PFI = "OR" expsoure #                        W114 F4
                                             ;       b4:7 = For FFI = ROI# of nROI                           Derived
                                             ;
                                             ;                                                                    PF
      periph: BYTE(0),  $                    ;  3- Aspect/shutter/filter information                         W114 F0
                                             ;       b7   = Aspect door (0=closed, 1=open)
                                             ;       b6   = Shutter mode (0=Frame Transfer, 1=Mech)
                                             ;       b3:5 = Filter B position
                                             ;               1 = Open
                                             ;               2 = Al 1400 Angstrom
                                             ;               3 = Al/Mg/Mn
                                             ;               4 = Ber 100 microns
                                             ;               5 = Al 12 microns
                                             ;               6 = Mg3Mu
                                             ;       b0:2 = Filter A position
                                             ;               1 = Open
                                             ;               2 = Narrow Band (4310 A, 30 A FWHM)
                                             ;               3 = Quartz defocusing lens ('photon flood')
                                             ;               4 = Diffuser
                                             ;               5 = Wide Band (4600 A, 185 A FWHM)
                                             ;               6 = Neutral Density Mask (8%)
      ExpLevMode: BYTE(0),  $                ;  4- Exposure mode/level                                       W114 F0
                                             ;       b6:7 = Exposure mode (0=normal, 1=dark, 2=LTF)
                                             ;       b0:5 = Mailbox exposure level
      imgparam: BYTE(0),  $                  ;  5- Image parameter information                               W114 F2
                                             ;       b6:7 = Exposure cadence (0=2sec,1=1sec,2=.5sec)
                                             ;       b4:5 = Number of ROI (0=1 ROI, 1=2 ROI, ...)
                                             ;       b2:3 = Compression (0=Cmp, 1=Low8, 2=Hi8)
                                             ;       b0:1 = Image resolution (0=1x1,1=2x2,3=4x4)
      flush: BYTE(0),  $                     ;  6- Flush information                                         W114 F4
                                             ;       b0:1 = Pre-exposure Full frame flushes (0-3)
                                             ;       b2:3 = Set-up full frame flushes
                                             ;               # flushes = 2*(b2:3 value) in ROM
                                             ;                       = 4*(b2:3 value) 30-sep-91 to 7-Oct-91?
                                             ;                       = 8*(b2:3 value) after 7-Oct-91
                                             ;       b4:7 = Guard band
      explat: LONG(0),  $                    ;  7- Exposure latency (mailbox value)                          W114 F1
      expdur: LONG(0),  $                    ; 11- Exposure duration (mailbox value)                         W114 F4
                                             ;
      shape_cmd: INTARR(2),  $               ; 15- Commanded image shape (nx by ny)                          W114 F5
                                             ;       (the col,lin# are in summed (output) pixels)
                                             ;     For observing regions, the "ny" is the 
                                             ;         full observing region size
                                             ;     For FFI, "nx" always = 1024, 512, or 256
                                             ;     For multiple ROI FFI "ny" is width of one ROI             W114 F3
      shape_sav: INTARR(2),  $               ; 19- Image shape saved (nx by ny)                              Derived
                                             ;       (the col,lin# are in summed (output) pixels)
                                             ;     For observing regions, "ny" always = 64
      corner_cmd: INTARR(2),  $              ; 23- Commanded starting corner (x0, y0)                        W114 F2
                                             ;       (the col,lin# are in 1x1 pixels)
                                             ;       The values are CCD column numbers and are NOT
                                             ;       reversed.  The SXT images have been reversed before
                                             ;       being written to disk so CCD column 0 is to the
                                             ;       right (high indcies) in the image array
                                             ;
                                             ;       Col 0 is "image-0", col 1 is "image-1"
                                             ;       in figure on page 97 of blue book.  Neither
                                             ;       of these pixels are summed in summation mode
                                             ;     For FFI, "x0" always = 0 (but check BLS on/off)
                                             ;     For multiple ROI FFI "y0" is the start of one ROI         W114 F3
      corner_sav: INTARR(2),  $              ; 27- Starting corner saved (x0, y0)                            Derived
                                             ;       (the col,lin# are in 1x1 pixels)
                                             ;
      FOV_Center: INTARR(2),  $              ; 31- Pitch and yaw relative to the sun center                  Derived
                                             ;     of the center of the SXT FOV (in arcsec)
                                             ;     (for the PFI strip, not the OR)
                                             ;       (1) = yaw; (2) = pitch 
                                             ;     (used to relate to active region list)
                                             ;       Temporary Definition:
                                             ;               yaw   = (512 - center_fov(0))*2.45
                                             ;               pitch = (center_fov(1) - 638)*2.45
                                             ;          where center_fov is pixel location in 1x1
                                             ;          pixels (not including the BLS pixels)
      FOV_Ver: FIX(0),  $                    ; 35- Information on how solution was derived                   Ground 
                                             ;
      ObsRegion: BYTE(0),  $                 ; 37- Observing region Number                                   W114 F5
                                             ;       b6:7 = FFI Seq Table # (0-3)
                                             ;               From Entry Table 
                                             ;       b4:5 = PFI Seq Table # (0-3)
                                             ;       b0:3 = Observing region number (0-8)
                                             ;               Location # on the sun
                                             ;               (0-3) Updated by QT ARS
                                             ;               (4-7) Updated manually (with ART option)
                                             ;               (8)   Updated by FL ARS
      seq_num: BYTE(0),  $                   ; 38- Sequence Number (1-13)                                    W114 F5
                                             ;       b0:3 = Entry in sequence table (1-13)
                                             ;       b4:7 = Word or line sync error bits
      seq_tab_serno: FIX(0),  $              ; 39- Sequence table serial used                                Ground 
                                             ;
      serial_num: LONG(0),  $                ; 41- Serial number of image                                    W115 F1
      mloop: LONG(0),  $                     ; 45- Main loop counter                                         W115 F1
      loops: BYTARR(4),  $                   ; 49- Loop counters     (1) = loop 2                            W115 F0
                                             ;                       (2) = loop 3                            W115 F2
                                             ;                       (3) = loop 4                            W115 F3
                                             ;                       (4) = loop 5                            W115 F5
                                             ;
      Pow_stat: BYTE(0),  $                  ; 53- Power Status (0=off, 1=on)                                W48  F2
                                             ;       b7 = 5 Volts
                                             ;       b6 = 28 Volts
                                             ;       b5 = Filter Wheel
                                             ;       b4 = Shutter / Aspect Controller
                                             ;       b3 = Micro A Select
                                             ;       b2 = Micro B Select
                                             ;       b1 = Camera
                                             ;       b0 = Thermoelectric Cooler (TEC)
      SW_stat: BYTE(0),  $                   ; 54- Active Software (1=active)                                W114 F1
                                             ;       b7 = Quiet ARS on/off
                                             ;       b6 = Quiet ARS 1 or 2
                                             ;       b5 = Flare ARS on/off
                                             ;       b4 = ARS morning patrol on/off
                                             ;       b3 = AEC patrol on/off
                                             ;       b2 = ART on/off
                                             ;       b1 = ART
                                             ;       b0 = ART
      SXT_Control: BYTE(0),  $               ; 55- SXT Control Status                                        W114 F3
                                             ;       b7   = Power control mode (1=auto, 0=manual)
                                             ;       b6   = SXT control mode (1=auto, 0=manual)
                                             ;       b4:5 = SXT day/night mode
                                             ;               00 = SXT day mode
                                             ;               01 = SXT evening mode
                                             ;               10 = SXT night mode
                                             ;               11 = SXT morning mode
                                             ;       b1   = SXTE-U hard reset (1=executed)
                                             ;       b0   = SXTE-U soft reset (1=executed)
      sxtfmt: BYTE(0),  $                    ; 56- SXT Format info 8:2 or 2:8                                W115 F0
                                             ;
      temp_ccd: BYTE(0),  $                  ; 57- CCD Temperature                                           W113 F5
                                             ;     Value is actually 1 MF out of sync?
      temp_hk: BYTARR(20),  $                ; 58- House keeping temperature                                 W32 F18
                                             ;     (See quasi-static section for conversions)
                                             ;       temp_hk(0) = 'Metering tube center'                     W32 F18
                                             ;       temp_hk(1) = 'Aspect Telescope (NOT FUNCTIONING)'       W32 F19
                                             ;       temp_hk(2) = 'Forward support plate (mirror) '          W32 F20
                                             ;       temp_hk(3) = 'Aft support plate (FW2T?)                 W32 F21
                                             ;       temp_hk(4) = 'Filter wheel housing (FW1T?)              W32 F22
                                             ;       temp_hk(5) = 'Shutter motor case                        W32 F23
                                             ;       temp_hk(6) = 'TSA (thermal strap) S/C end               W32 F24
                                             ;       temp_hk(7) = 'TEC hot end'                              W32 F25
                                             ;       temp_hk(8) = 'CCD camera head'                          W32 F26
                                             ;       temp_hk(9)  = Upper Panel Sensor 4 (UP-4)               W32 F42
                                             ;       temp_hk(10) = Cemter Panel Sensor 1 (CP-1)              W32 F55
                                             ;       temp_hk(11) = Center Panel Sensor 2 (CP-2)              W32 F56
                                             ;       temp_hk(12) = Center Panel Sensor 3 (CP-3)              W32 F57
                                             ;       temp_hk(13) = Base Panel Sensor 4 (BP-4)                W32 F61
                                             ;       temp_hk(14) = (spare)
                                             ;       temp_hk(15) = (spare)
                                             ;       temp_hk(16) = (spare)
                                             ;       temp_hk(17) = (spare)
                                             ;       temp_hk(18) = (spare)
                                             ;
      HW_error: BYTARR(2),  $                ; 78- Hardware error since last exposure                        W113 F0
      j_register: BYTE(0),  $                ; 80- Which buffer is used                                      W114 F3
                                             ;
      Img_Max: BYTE(0),  $                   ; 81- Maximum intensity                                         Derived
                                             ;     (0-255, high 8 bits)
                                             ;     The image is decompressed first where necessary
      Img_Avg: BYTE(0),  $                   ; 82- Average intensity of whole image                          Derived
                                             ;       1x1 - first subtract 12.8 DN offset
                                             ;       2x4 - first subtract 30.7 DN offset
                                             ;       4x4 - first subtract 73.6 DN offset
                                             ;     (0-255, high 8 bits)
                                             ;     The image is decompressed first where necessary
      Img_Dev: BYTE(0),  $                   ; 83- Standard deviation of the whole image                     Derived
                                             ;     (0-255) - Not scaled
                                             ;     The image is decompressed first where necessary
      PercentD: BYTE(0),  $                  ; 84- Percentage of data present                                Derived
                                             ;     (value 255 = 100%)
      PercentOver: BYTE(0),  $               ; 85- Percentage of data over [N] counts                        Derived
                                             ;     (value 255 = 100%)
                                             ;       1x1 - the # pixels over 2000 DN (decompressed)
                                             ;       2x2 - the # pixels over 3500 DN (decompressed)
                                             ;       4x4 - the # pixels over 3500 DN (decompressed)
                                             ;
      AEC_Status: BYTE(0),  $                ; 86- AEC Status                                                W114 F4
                                             ;       NOTE: True only for the LAST "PFI Strip" in
                                             ;             an observing region
                                             ;       b4:7 = Maximum number of selcted regions
                                             ;              in AT ARS1 (0-4)
                                             ;       b2:3 = AEC Status of PFI-AEC
                                             ;               00b = proper
                                             ;               01b = Over exposure
                                             ;               10b = Under exposure
                                             ;       b0:1 = AEC Status of Patrol-AEC
                                             ;               (see PFI-AEC above)
      extra: LONG(0),  $                     ; 87- Information used by secondary programs
                                             ;       * In SSC, SSE, and SSW files it is the
                                             ;         offset time in millisec from the central
                                             ;         meridian time
      spare: BYTARR(5) }                     ; 87- Spare bytes
   
   
   
SXT_3021_Gnd_Idx = { SXT_3021_Gnd_Idx_Rec,              $
      index_version : FIX('3021'x),  $       ;
                                             ; 00- Index structure version
                                             ;
      st$filename: BYTARR(16),  $            ;  2- MicroVAX file name
                                             ;
      st$experiment: BYTARR(6),  $           ; 18- Description of experiment
      st$source: BYTARR(6),  $               ; 24- Description of the source
      st$ccddev: BYTARR(6),  $               ; 30- CCD used
                                             ;
      x: LONG(0),  $                         ; 36- Translation Stage X Position
      y: LONG(0),  $                         ; 40- Translation Stage Y Position
      z: LONG(0),  $                         ; 44- Translation Stage Z Position
                                             ;
      az: LONG(0),  $                        ; 48- Azimuth of MSFC optical bench (in .1 arcsec units)
      el: LONG(0),  $                        ; 52- Azimuth of MSFC optical bench (in .1 arcsec units)
      cexp: LONG(0),  $                      ; 56- Commanded exposure duration (usec)
      aexp: LONG(0),  $                      ; 60- Actual exposure duration (usec)
                                             ;
      st$filta: BYTARR(6),  $                ; 64- Filter A name (since filters were changed over testing period)
      st$filtb: BYTARR(6),  $                ; 70- Filter B name
                                             ;
      st$soufilename: BYTARR(16),  $         ; 76- MicroVAX source file name
                                             ;     (for cases of dark current subtraction)
      st$dcfilename: BYTARR(16),  $          ; 92- MicroVAX dark current file name
                                             ;     (for cases of dark current subtraction)
                                             ;
      nimg_sum: FIX(0),  $                   ;108- The number of images summed together (SD files)   
      spare: BYTARR(18) }                    ;108- Spare bytes
   
   
   
SXT_3032_Proc_Idx = { SXT_3032_Proc_Idx_Rec,              $
      index_version : FIX('3032'x),  $       ;
                                             ;  0- Index structure version
                                             ;
                                             ;--------------------------------------------------------------------
      q_subimg: FIX(0),  $                   ;  2- Whether the image was extracted from an FFI image
                                             ;       0 = not done
                                             ;       non-zero = the EXT_SUMIMG2 procedure version number ??
      corner_ext: INTARR(2),  $              ;   - corner extracted
                                             ;       { RD_AR type information when tracking the rotation of an activ
      shape_ext: INTARR(2),  $               ;   - shape extracted.  This might not match SHAPE_SAV since the regist
                                             ;     of the images might make the image slightly larger.
                                             ;
                                             ;--------------------------------------------------------------------
      q_12bit: FIX(0),  $                    ;  - Whether the image was reconstructed from a low-8 image
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      time_12bit: LONARR(2),  $              ;   - The time of the images used in the reconstruction of the 12 bit i
                                             ;               (0) = low-8 image
                                             ;               (1) = compressed or high-8 image
      day_12bit: INTARR(2),  $               ;   - The days of the images used
                                             ;
                                             ;--------------------------------------------------------------------
      q_dark_sub: FIX(0),  $                 ;   - Whether the dark current was subtracted.
                                             ;       0 = not done
                                             ;       non-zero = the DARK_SUB procedure version number
      time_dark: LONARR(2),  $               ;   - The time of the images used in the dark current subtraction
      day_dark: INTARR(2),  $                ;   - The days of the images used
                                             ;
                                             ;--------------------------------------------------------------------
      q_leak_sub: FIX(0),  $                 ;   - Whether the leak image was subtracted.
                                             ;       0 = not done
                                             ;       non-zero = the LEAK_SUB procedure version number
      time_leak: LONG(0),  $                 ;   - The time of the images used in the leak subtraction
      day_leak: FIX(0),  $                   ;   - The days of the images used 
                                             ;
                                             ;--------------------------------------------------------------------
      q_exp_norm: FIX(0),  $                 ;   - Whether the image was normalized for exposure 
                                             ;       0 = not done
                                             ;       non-zero = the EXP_NORM procedure version number
      expdur: FLOAT(0),  $                   ;   - the exposure value in seconds that the image was normalized to.  
                                             ;     normally be 1.00 sec.
                                             ;       ## EXP_NORM will write to this
                                             ;       ** GT_EXPDUR will default to this value if this structure is pa
                                             ;
                                             ;--------------------------------------------------------------------
      pixel_size: FLOAT(0),  $               ;   - The pixel size.  
                                             ;       Value Greater or Equal to 0 == It is 0, 1, or 2 for FR, HR, and
                                             ;       Value Less Than 0 ===== It is the pixels size in arc seconds (s
                                             ;                               always be FR, HR, QR)
                                             ;       ## CHANGE_RES, MK_MOSAIC, EXT_SUBIMG2 will write to this
                                             ;       ** GT_RES will default to this value if this structure is part 
                                             ;
                                             ;--------------------------------------------------------------------
      q_registered: FIX(0),  $               ;   - Whether the image was registered
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      reg_program: FIX(0),  $                ;   - The program that did the registration
                                             ;               1 = ALIGN_AR
                                             ;               2 = FFI2PFI
      q_reg_bef_ass: FIX(0),  $              ;   - Whether the image was registered before the observing region mosa
      q_sun_rot: FIX(0),  $                  ;   - Whether the registration was done trying to make the image track
                                             ;     a location on the sun as it rotates
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
                                             ;
      q_roll_corr: FIX(0),  $                ;   - Whether the roll correction was performed.  See the variable .SUN
                                             ;     to get the amount of roll that was corrected.
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
                                             ;
      arcsec_shift: FLTARR(2),  $            ;   - Relative shift.  The number of arcseconds that the image was shif
                                             ;     in order to register it.  (0) = E/W with a positive value meaning
                                             ;     that the image was moved to the east??.  (1) = N/S with positive 
                                             ;     meaning that
      corner_sav: FLTARR(2),  $              ;   - the new corner saved in absolute IDL FR pixels.  If all of the im
                                             ;     the same size and have been registered, this value should be the
                                             ;     same for all images, but there are cases when there are different
                                             ;     field of view sizes are saved in one file.
                                             ;       ## CHANGE_RES, MK_MOSAIC will write to this
                                             ;       ** GT_CORNER_SAV will default to this value if this structure i
      sun_center: FLTARR(3),  $              ;   - the location of the center of the sun in absolute IDL FR pixels. 
                                             ;     value is most likely the result of the routine GET_SUNCENTER.
                                             ;     From SUN_CENTER and CORNER_SAV it is possible to get the absolute
                                             ;     of the lower right corner in arcseconds relative to sun center (a
                                             ;     center of the field of view can be derived from SHAPE_SAV and PIX
                                             ;               (0) = X location
                                             ;               (1) = Y location
                                             ;               (2) = roll (clockwise?)
      sun_center_ver: FIX(0),  $             ;   - The program version number used to get the SUN_CENTER results.
                                             ;
                                             ;--------------------------------------------------------------------
      q_merged: FIX(0),  $                   ;   - Whether parts of other images were merged into the image
                                             ;     Fill in the gaps with a larger FOV image (Barry Labonte program)
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      time_merged: LONG(0),  $               ;   - The time of the image used to fill in the gaps
      day_merged: FIX(0),  $                 ;   - The days of the image used 
                                             ;
                                             ;--------------------------------------------------------------------
      q_interp: FIX(0),  $                   ;   - Whether the image was interpolated between two images
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      time_interp: LONARR(2),  $             ;   - The time of the images used in the interpolation
      day_interp: INTARR(2),  $              ;   - The days of the images used 
                                             ;
                                             ;--------------------------------------------------------------------
      q_composite: FIX(0),  $                ;   - Whether the output image is a composite image
      time_compos: LONARR(3),  $             ;   - The time of the composite image(s)
      day_compos: INTARR(3),  $              ;   - The day of the composite image(s)
                                             ;
                                             ;--------------------------------------------------------------------
      q_projection: FIX(0),  $               ;   - Whether the image projection was changed
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      proj_tech: FIX(0),  $                  ;   - The projection technique
                                             ;       An further expanded index structure will probably be needed for
                                             ;
                                             ;--------------------------------------------------------------------
      qflat_field: FIX(0),  $                ;   - Whether the image was flat fielded
                                             ;       0 = not done
                                             ;       non-zero = the ??? procedure version number
      flat_tech: FIX(0),  $                  ;   - The technique used
                                             ;
                                             ;--------------------------------------------------------------------
      q_compression: FIX(0),  $              ;   - Whether the data was recompressed
                                             ;       0 = uncompressed
                                             ;       1 = SXT standard compression
                                             ;       2 = SFD compression
                                             ;
                                             ;--------------------------------------------------------------------
      percentd: BYTE(0),  $                  ;   - Updated percentd field
      percentOver: BYTE(0),  $               ;   - Updated percent over field
                                             ;
                                             ;--------------------------------------------------------------------
      q_extra: INTARR(2),  $                 ;   - spare fields for unknown programs and users to use as they wish
      extra1: LONARR(2),  $                  ;
      extra2: FLTARR(2),  $                  ;
                                             ;
      spare: BYTARR(4) }                     ;   - Spare bytes
   
   
   
SXT_RoadMap = { SXT_RoadMap_Rec,              $
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
      pfi_ffi: BYTE(0),  $                   ; 12- Image information 
      periph: BYTE(0),  $                    ; 13- Aspect/Shutter/Filter information
      ExpLevMode: BYTE(0),  $                ; 14- Exposure mode/level       
      imgparam: BYTE(0),  $                  ; 15- Image parameter information 
                                             ;
      ObsRegion: BYTE(0),  $                 ; 16- Observing region Number
      seq_num: BYTE(0),  $                   ; 17- Sequence Number (1-13)
                                             ;
      shape_cmd: INTARR(2),  $               ; 18- Commanded image shape (nx by ny)
      FOV_Center: INTARR(2),  $              ; 22- Pitch and yaw relative to the sun center
                                             ;     of the center of the SXT FOV (in arcsec)
                                             ;
      Img_Max: BYTE(0),  $                   ; 26- Maximum intensity
      Img_Avg: BYTE(0),  $                   ; 27- Average intensity of whole image
      Img_Dev: BYTE(0),  $                   ; 28- Average intensity around the max
      PercentD: BYTE(0),  $                  ; 29- Percentage of data present
      PercentOver: BYTE(0),  $               ; 30- Percentage of data over [N] counts
                                             ;
      Flare_Status: BYTE(0),  $              ; 31- Flare flag status 
                                             ;
      serial_num: LONG(0),  $                ; 32- Serial number of image
                                             ;     ** NOT INCLUDED IN OBSERVING LOG **
      AEC_Status: BYTE(0),  $                ; 36- AEC Status
                                             ;     ** NOT INCLUDED IN OBSERVING LOG **
      seq_tab_serno: FIX(0),  $              ; 37- Sequence table serial used 
      spare2: BYTARR(9) }                    ; 39- Spare bytes
   
   
   
SXT_Version = { SXT_Version_Rec,              $
      roadmap : FIX('30F1'x),  $             ;
                                             ; 00- The version number of the Roadmap
                                             ;     This value is not contained in the
                                             ;     roadmap structure to save space.  It is
                                             ;     saved in the "File Header Record"
                                             ;
                                             ;     This structure is not written to any files
      SSL : FIX('3041'x),  $                 ;   - SXT Summary log
      SRD : FIX('3051'x),  $                 ;   - SXT RAM Dump
      SDL : FIX('3061'x),  $                 ;   - SXT Dark current log
      SEL : FIX('3071'x),  $                 ;   - SXT Engineering log
      SOT : FIX('3081'x),  $                 ;   - SXT Optical telescope
      SXL : FIX('3091'x),  $                 ;   - SXT Xray log
      SXL2 : FIX('3092'x),  $                ;   - SXT Xray log
      SXG : FIX('3093'x),  $                 ;   - SXT/GOES XRay log
      sxl_roadmap : FIX('39F1'x),  $         ;
      SL  : FIX('30A1'x),  $                 ;   - SXT Leak log
                                             ;   - SXT Xray Log Roadmap
      SXC : FIX('30B1'x),  $                 ;   - SXT Xray Sun Center
      spare: BYTARR(10) }                    ;     (need for automatic conversion to IDL format)
   
   
   
SXT_3041_SumLog = { SXT_3041_SumLog_Rec,              $
      time: LONG(0),  $                      ;  0- Time (millisec of day)
      day: FIX(0),  $                        ;  4- Day (since 1-Jan-79)
                                             ;
                                             ;     ------------ Number and Types of Exposure Information -----------
      pfi_sernum: LONARR(2),  $              ;   - The PFI serial number
                                             ;       (0) = at beginning of 24 hour period
                                             ;       (1) = at end of 24 hour period
      ffi_sernum: LONARR(2),  $              ;   - The FFI serial number
                                             ;       (0) = at beginning of 24 hour period
                                             ;       (1) = at end of 24 hour period
      pfi_qt: INTARR(2),  $                  ;   - The number of PFI images available in quiet mode
                                             ;       (0) = PFI strips (exposures) separate datasets
                                             ;       (1) = PFI Observing Regions (ORs)
      pfi_fl: INTARR(2),  $                  ;   - The number of PFI images available in flare mode
                                             ;       (0) = PFI strips (exposures) separate datasets
                                             ;       (1) = PFI Observing Regions (ORs)
      ffi_qt: FIX(0),  $                     ;   - The number of FFI images available in quiet mode
      ffi_buff: FIX(0),  $                   ;   - The number of FFI image buffer dumps (patrol images,...)
      pfi_hi_cad: FIX(0),  $                 ;   - The number of high cadence PFI images
      odom: LONARR(4,3),  $                  ;   - The SXTE-U odometer values
                                             ;       (i,j)
                                             ;               i = 0 for filter-A moves
                                             ;               i = 1 for filter-B moves
                                             ;               i = 2 for shutter moves
                                             ;               i = 3 for aspect door moves
                                             ;
                                             ;               j = 0 for beginning of 24 hour period
                                             ;               j = 1 for end of 24 hour period
                                             ;               j = 2 is the max (in case of hard reset)
      num_expos: LONARR(13),  $              ;   - Number of exposures received by the ground and reformatted
                                             ;                0 = Al 1400 Angstrom                (Filter B = 2)
                                             ;                1 = Al/Mg/Mn                        (Filter B = 3)
                                             ;                2 = Ber 100 microns                 (Filter B = 4)
                                             ;                3 = Al 12 microns                   (Filter B = 5)
                                             ;                4 = Mg3Mu                           (Filter B = 6)
                                             ;                5 = Narrow Band (4310 A, 30 A FWHM) (Filter A = 2)
                                             ;                6 = Quartz defocusing lens          (Filter A = 3)
                                             ;                7 = Diffuser                        (Filter A = 4)
                                             ;                8 = Wide Band (4600 A, 185 A FWHM)  (Filter A = 5)
                                             ;                9 = Neutral Density Mask (8%)       (Filter A = 6)
                                             ;               10 = OPEN/OPEN
                                             ;               11 = Dark images
                                             ;               12 = Calibration (LTF) images
      dur_expos: LONARR(13),  $              ;   - The total number of milliseconds that the CCD was exposed
                                             ;     to each of the previous filters/exposure modes.
                                             ;     Effective exposure (takes neutral density mask into account)
                                             ;
                                             ;     ------------ Solar and RBM Activity Information ------------
      avg_rbmsd: FIX(0),  $                  ;   - The average RBM detected in cnts/sec
      max_rbmsd: FIX(0),  $                  ;   - The maximum RBM detected in cnts/sec
      avg_sxs1: FIX(0),  $                   ;   - The average SXS1 detected in cnts/sec
      max_sxs1: FIX(0),  $                   ;   - The maximum SXS1 detected in cnts/sec
      avg_sxs2: FIX(0),  $                   ;   - The average SXS2 detected in cnts/sec
      max_sxs2: FIX(0),  $                   ;   - The maximum SXS2 detected in cnts/sec
      avg_hxt_sum_l: FIX(0),  $              ;   - The average HXT Low channel detected in cnts/sec
      max_hxt_sum_l: FIX(0),  $              ;   - The maximum HXT low channel detected in cnts/sec
                                             ;
                                             ;     ------------ Shutter performance information ------------
      n_expdur: INTARR(32),  $               ;
      avg_expdur: LONARR(32),  $             ;   - The average exposure duration for each MBE
                                             ;     for normal exposures
                                             ;               (i) is for MBE "i"
      min_expdur: LONARR(32),  $             ;   - The minimum exposure duration for each MBE
      max_expdur: LONARR(32),  $             ;   - The maximum exposure duration for each MBE
                                             ;
      avg_explat_norm: LONG(0),  $           ;   - The average exposure latency for normal exposure
      min_explat_norm: LONG(0),  $           ;   - The minimum exposure latency for normal exposure
      max_explat_norm: LONG(0),  $           ;   - The maximum exposure latency for normal exposure
                                             ;
      avg_explat_dark: LONG(0),  $           ;   - The average exposure latency for dark image exposures
      min_explat_dark: LONG(0),  $           ;   - The minimum exposure latency for dark image exposures
      max_explat_dark: LONG(0),  $           ;   - The maximum exposure latency for dark image exposures
                                             ;
                                             ;     ------------ Error information ------------
      max_err_odom: BYTARR(5),  $            ;  6- The maximum seen in the error odometer for various sub-systems
                                             ;               i = 0 for filter soft errors
                                             ;               i = 1 for filter hard errors
                                             ;               i = 2 for aspect door soft error
                                             ;               i = 3 for aspect door hard error
                                             ;               i = 4 for shutter
      u_hardreset: BYTE(0),  $               ;   - The number of hard reset transitions observed for the
                                             ;     24 hour period.
                                             ;     (by looking for transition in bit 3 of status 4)
      j_hardreset: BYTE(0),  $               ;   - The number of hard resets as determined by SXTE-J W114 F32
                                             ;     (should match "hardreset" but there was one time when a
                                             ;     hardreset occurred by unknown mechanism)
      j_softreset: BYTE(0),  $               ;   - The number of hard resets as determined by SXTE-J W114 F32
      error1: BYTE(0),  $                    ;   - SXTE-U error word 1 "ORed" for all values observed during
                                             ;     the 24 hour period
      error2: BYTE(0),  $                    ;   - SXTE-U error word 2 "ORed" for all values observed during
                                             ;     the 24 hour period
                                             ;
                                             ;     ------------ Temperature information ------------
      avg_temp_hk: BYTARR(15),  $            ;   - Average temperature over the 24 hour period
      min_temp_hk: BYTARR(15),  $            ;   - Minimum temperature over the 24 hour period
      max_temp_hk: BYTARR(15),  $            ;   - Maximum temperature over the 24 hour period
                                             ;     (See SXT_INDEX for description of sensors)
      avg_temp_ccd: BYTE(0),  $              ;   - Average CCD temperature
      min_temp_ccd: BYTE(0),  $              ;   - Minimum CCD temperature
      max_temp_ccd: BYTE(0),  $              ;   - Maximum CCD temperature
                                             ;
                                             ;     ------------ Status information ------------
      aspect_encode: BYTE(0),  $             ;   - Tracking aspect door position (open /closed)
                                             ;     (by looking at bits 1 and 2 of status 4)
                                             ;               0 = invalid
                                             ;               1 = open?
                                             ;               2 = closed?
                                             ;               3 = open and closed during 24 hours
                                             ;                   (or error)
                                             ;
      Pow_stat: BYTE(0),  $                  ; 52- Power Status (0=off, 1=on) for beginnning of 24 hour period
                                             ;     (See SXT_INDEX for description of bits)
      SW_stat: BYTE(0),  $                   ; 53- Active Software (1=active) for beginning of 24 hour period
                                             ;     (See SXT_INDEX for description of bits)
                                             ;
                                             ;
      spare: BYTARR(15) }                    ;   - Spare bytes
   
   
   
SXT_3051_RAMDump = { SXT_3051_RAMDump_Rec,              $
      time: LONG(0),  $                      ;  0- Time (millisec of day)
      day: FIX(0),  $                        ;  4- Day (since 1-Jan-79)
                                             ;
      address: FIX(0),  $                    ;  6- Address of the dump
      nbyte: BYTE(0),  $                     ;  8- Number of bytes of dump
      dump: BYTARR(61),  $                   ;  9- Dump data
                                             ;
      spare: BYTARR(10) }                    ; 70- spare
   
   
   
SXT_3061_DarkLog = { SXT_3061_DarkLog_Rec,              $
      hist: LONARR(256),  $                  ;   0- The IDL histogram of the image
                                             ;
      x: INTARR(128),  $                     ;1024- The column number of 128 brightest pixels
                                             ;      in image array coordinates (not CCD coordinates)
      y: INTARR(128),  $                     ;1280- The line number of 128 brightest pixels
                                             ;      in image array coordinates (not CCD coordinates)
      int: BYTARR(128) }                     ;1536- The intensity of the 128 brightest pixels
   
   
   
SXT_3071_EnginLog = { SXT_3071_EnginLog_Rec,              $
      time: LONG(0),  $                      ; 02- Time (millisec of day)                                    Derived
      day: FIX(0),  $                        ; 06- Day (since 1-Jan-79)                                      Derived
      DP_mode: BYTE(0),  $                   ; 12- DP Mode                                                   W50 F2
                                             ;     (See GEN_STRUCT for description of bits)
      DP_rate: BYTE(0),  $                   ; 13- DP Rate                                                   W48 F15
                                             ;     (See GEN_STRUCT for description of bits)
                                             ;
      SXT_Pow_stat: BYTE(0),  $              ; 58- Power Status (0=off, 1=on)                                W48  F2
                                             ;     (See SXT_INDEX for description of bits)
      SXT_Control: BYTE(0),  $               ; 62- SXT Control Status                                        W114 F3
                                             ;     (See SXT_INDEX for description of bits)
      sxt_temps: BYTARR(15),  $              ; sxt temperatures 
                                             ;     (See SXT_INDEX for description of bits)
      heaters: BYTE(0),  $                   ;     The status of the headers (on/off)
                                             ;
      os1_status1: BYTARR(8),  $             ;
      os1_status2: BYTARR(8),  $             ;
      os1_status3: BYTE(0),  $               ;
      os1_status4: BYTE(0),  $               ;
                                             ;
      os1_fwacomand: BYTE(0),  $             ;
      os1_flushcommand: BYTE(0),  $          ;
                                             ;
      os1_explatency: FIX(0),  $             ;
      os1_expduration: FIX(0),  $            ;
      os1_mbe: BYTE(0),  $                   ;
                                             ;
      os1_fwaodoma: FIX(0),  $               ;low/mid
      os1_fwaodomb: FIX(0),  $               ;low/mid
      os1_shutterodom: FIX(0),  $            ;low/mid
      os1_aspectodom: FIX(0),  $             ;
                                             ;
      os1_error1: BYTARR(2),  $              ;
      os1_error2: BYTARR(2),  $              ;
      os1_fwasoft: BYTE(0),  $               ;
      os1_fwahard: BYTE(0),  $               ;
      os1_aspectsoft: BYTE(0),  $            ;
      os1_shutterhard: BYTE(0) }             ;
   
   
   
SXT_3081_OptTel = { SXT_3081_OptTel_Rec,              $
      st$fileid: BYTARR(12),  $              ; 06
      dset: FIX(0),  $                       ; 18
                                             ;
      x: FLOAT(0),  $                        ; 20- Center in image array coordinates
      y: FLOAT(0),  $                        ; 24-
      find_limb: FLTARR(10),  $              ; 28- FIND_LIMB results
                                             ;               (0) = x in 1x1 pixels
                                             ;               (1) = y
                                             ;               (2) = radius
                                             ;               (3) = r_err
                                             ;               (4) = oblateness
                                             ;               (5) = oblateness angle
                                             ;               (6) = "bias"
                                             ;               (7) = brightness
                                             ;
      avg: FLOAT(0),  $                      ; 68-
      bkg: FLOAT(0),  $                      ; 72-
      flux: FLOAT(0),  $                     ;
                                             ;
      ocenter: FLTARR(3),  $                 ;   - OCENTER results
                                             ;               (0) = x in 1x1 pixels (E/W)
                                             ;               (1) = y in 1x1 pixels (N/S)
                                             ;               (2) = radius in 1x1 pixels
                                             ;
      spare: BYTARR(10) }                    ; 82
   
   
   
SXT_30B1_XrCen = { SXT_30B1_XrCen_Rec,              $
      st$fileid: BYTARR(12),  $              ;  0
      dset: FIX(0),  $                       ; 12
                                             ;
      x: FLOAT(0),  $                        ; 14- Center in image array coordinates
      y: FLOAT(0),  $                        ; 18-
      sxt_center: FLTARR(10),  $             ; 22- SXT_CENTER results
                                             ;               (0) = x in 1x1 pixels
                                             ;               (1) = y
                                             ;               (2) = radius
                                             ;               (3) = r_err
                                             ;
      suncenter: FLTARR(4),  $               ; 62- GET_SUNCENTER results
                                             ;               (0) = x in 1x1 pixels (E/W)
                                             ;               (1) = y in 1x1 pixels (N/S)
                                             ;               (2) = delta in seconds between image and pnt record
                                             ;
      spare: BYTARR(18) }                    ; 78
   
   
   
SXT_3091_XrayLog = { SXT_3091_XrayLog_Rec,              $
      hist: LONARR(256) }                    ;   0- The IDL histogram of the image
   
   
   
SXT_3092_Xray2Log = { SXT_3092_Xray2Log_Rec,              $
                                             ;       (*,0) = histogram of whole image
                                             ;       (*,1) = histogram of image within 0.86 * radius
                                             ;       (*,2) = histogram of image outside of 1.05 * radius
      hist: LONARR(256,3) }                  ;   0- The IDL histogram of the image
   
   
   
SXL_39F1_RoadMap = { SXL_39F1_RoadMap_Rec,              $
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
      pfi_ffi: BYTE(0),  $                   ; 12- Image information 
      periph: BYTE(0),  $                    ; 13- Aspect/Shutter/Filter information
      ExpLevMode: BYTE(0),  $                ; 14- Exposure mode/level       
      imgparam: BYTE(0),  $                  ; 15- Image parameter information 
                                             ;
      seq_num: BYTE(0),  $                   ; 16- Sequence Number (1-13)
      seq_tab_serno: FIX(0),  $              ; 17- Sequence table serial used 
                                             ;
      Img_Avg: FLOAT(0),  $                  ; 19- Average intensity of whole image
      Img_Dev: FLOAT(0),  $                  ; 23- Average intensity around the max
                                             ;
      spare: BYTARR(5) }                     ; 27- Spare bytes
   
   
   
SXG_39F1_SXTGOES = { SXG_39F1_SXTGOES_Log,              $
                                             ;
                                             ; Time Tag and SXT params from SXL Record
      time: LONG(0),  $                      ; 00- Major frame time (millisec of day)
      day: FIX(0),  $                        ; 04- Major frame day (since 1-Jan-79)
      periph: BYTE(0),  $                    ; 06- Aspect/Shutter/Filter information
      ExpLevMode: BYTE(0),  $                ; 07- Exposure mode/level       
      imgparam: BYTE(0),  $                  ; 08- Image parameter information 
      DP_mode: BYTE(0),  $                   ; 09- DP Mode
      temp_ccd: BYTE(0),  $                  ; 10- CCD Temp.
      sxt_flux: LONG(0),  $                  ; 11- DN/s from SXL Histogram
                                             ;
                                             ; GOES info from GXD file
      LO: FLOAT(0),  $                       ; 15-  GOES low energy
      HI: FLOAT(0),  $                       ; 19 - GOES Hi energy
      deltaT: FIX(0),  $                     ; 23 - Tsxt-Tgoes (seconds)
      goes_status: BYTE(0),  $               ; 25 - satellite (b:0-3)={6,7,8}
                                             ;      type(b:4:7); 0=> 3second
                                             ;                   1=> 1 min avg
                                             ;                   2=> 5 min avg
                                             ;      
      spare: BYTARR(6) }                     ; 26 spare
   
   
   
SXT_30A1_Leak = { SXT_30A1_Leak_Rec,              $
      st$fileid: BYTARR(12),  $              ; 06
      dset: FIX(0),  $                       ; 18
                                             ;
      y0: FIX(0),  $                         ;   - Starting line of average in FR pixels
      y1: FIX(0),  $                         ;   - Ending line of average in FR pixels
      avg_arr: FLTARR(51),  $                ;   - Strip averages - 20 FR columns per element
                                             ;               (10 HR, 5 QR).  Starting column
                                             ;               is "i*20/sum+1"
                                             ;
      spare: BYTARR(18) }                    ; 82
   
   
   
  
  
end
