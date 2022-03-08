pro gbo_struct, GEV_Data = GEV_Data,  $
                     GXR_Data = GXR_Data,  $
                     GXR2_Data = GXR2_Data,  $
                     GXD_Data = GXD_Data,  $
                     NAR_Data = NAR_Data,  $
                     GSN_ObsHeader = GSN_ObsHeader,  $
                     GSN_ObsImage = GSN_ObsImage,  $
                     GBO_Obs = GBO_Obs,  $
                     BATSE_Event = BATSE_Event,  $
                     BATSE_LCur = BATSE_LCur,  $
                     Nob_Event = Nob_Event,  $
                     Nob_TimSer = Nob_TimSer,  $
                     GBO_Version = GBO_Version,  $
                     Uly_FEM = Uly_FEM
   
   
;+
;       NAME:
;               GBO_STRUCT
;       PURPOSE:
;               Define the following ground Based Observing database structures
;                       * GEV_Data_Rec
;                       * GXR_Data_Rec
;                       * GDR_Data_Rec
;                       * NAV_Data_Rec
;                       * GBO_Version_Rec
;                       * GSN_ObsHeader_rec
;                       * GSN_ObsImage_rec
;                       * GBO_Obs_rec
;                       * BATSE_Event_Rec
;                       * BATSE_LCur_Rec
;                       * Nob_Event_Rec
;                       * Nob_TimSer_Rec
;                       * Uly_FEM_Rec
;
;       CALLING SEQUENCE:
;               GBO_STRUCT
;       HISTORY:
;               written by Mons Morrison, Jun-92
;               slf, 23-sep-92, added GXR_Data_Rec, modified GBO_Version_Rec
;               slf, 10-oct-92, changed number pad bytes, GXR_Data_Rec
;
;-
   
   
GEV_Data = { GEV_Data_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      peak: LONG(0),  $                      ; 06- The number of seconds past the start time that the
                                             ;     peak intensity occurs
      duration: LONG(0),  $                  ; 10- The number of seconds that the event lasts
      st$class: BYTARR(4),  $                ; 14- The GOES classification (ie: X3.3)
      st$halpha: BYTARR(2),  $               ; 18- The H-alpha importance (ie: 3B)
      location: INTARR(2),  $                ; 20- The location in heliocentric coordinates
                                             ;     Values are in degrees
                                             ;       (0) = E/W (E is negative)
                                             ;       (1) = N/S (S is negative)
                                             ;     A value of -999 means that there was no data available
      noaa: FIX(0),  $                       ; 24- NOAA active region number
      radio: INTARR(3),  $                   ; 26- The radio flux at (2.7, 8.8, 15.4)
      st$comment: BYTARR(20),  $             ; 32- The comment notations
                                             ;       II, III, IV, V, C = Type II, III, IV, V, or continuum
                                             ;               radio burst reported, respectively
                                             ;                       L = loop prominence system reported
                                             ;                       S = spray reported
                                             ;                       B = bright surge on limb reported
                                             ;                       E = eruptive prominence reported
      spare: BYTARR(12) }                    ; 52- Spare
   
   
   
GXR_Data = { GXR_Data_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      g7lo: FIX(0),  $                       ; Goes 7 Low energy count rate
      g6lo: FIX(0),  $                       ; Goes 6 Low energy count rate
      g7hi: FIX(0),  $                       ; Goes 7 High energy count rate
      g6hi: FIX(0),  $                       ; Goes 6 High energy count rate
      digitize: BYTE(0),  $                  ; Digitization Method:
                                             ;    1 = Tektronics, 6 hour plot derived
                                             ;        Datrng=[101,679]->[1E-9,1E-3] , log
      spare: BYTARR(1) }                     ; Spare (from 6 to 1, 10-oct-92, slf)
   
   
   
GXR2_Data = { GXR2_Data_rec,              $
                                             ;       This structure is not saved on disk, it is created
                                             ;       when reading the GXR_Data_Rec Structure
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      g7lo: FLOAT(0),  $                     ; Goes 7 Low energy count rate
      g6lo: FLOAT(0),  $                     ; Goes 6 Low energy count rate
      g7hi: FLOAT(0),  $                     ; Goes 7 High energy count rate
      g6hi: FLOAT(0),  $                     ; Goes 6 High energy count rate
      digitize: BYTE(0),  $                  ; Digitization Method:
                                             ;    1 = Tektronics, 6 hour plot derived
                                             ;        Datrng=[101,679]->[1E-9,1E-3] , log
                                             ;    2 = Converted into reals
      spare: BYTARR(1) }                     ; Spare (from 6 to 1, 10-oct-92, slf)
   
   
   
GXD_Data = { GXD_Data_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      lo: FLOAT(0),  $                       ; 06- Low energy count rate
      hi: FLOAT(0),  $                       ; 10- High energy count rate
      spare: BYTARR(2) }                     ; 14- Spare (from 6 to 1, 10-oct-92, slf)
   
   
   
NAR_Data = { NAR_Data_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      noaa: FIX(0),  $                       ; 06- NOAA active region number
      location: INTARR(2),  $                ; 08- The location in heliocentric coordinates
                                             ;     Values are in degrees
                                             ;       (0) = E/W (E is negative)
                                             ;       (1) = N/S (S is negative)
                                             ;     A value of -999 means that there was no data available
      longitude: FIX(0),  $                  ; 12- longitude of active region
      area: FIX(0),  $                       ; 14- Area of active region in millionths
      st$macintosh: BYTARR(3),  $            ; 16- MacIntosh classification
                                             ;       Details ??
      long_ext: FIX(0),  $                   ; 19- longitude extent in degrees
      num_spots: FIX(0),  $                  ; 21- number of spots
      st$mag_type: BYTARR(16),  $            ; 23- Magnetic type
                                             ;       ALPHA
                                             ;       BETA
                                             ;       GAMMA
      spare: BYTARR(9) }                     ; 39-
   
   
   
GSN_ObsHeader = { GSN_ObsHeader_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day) of first image
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79) of first image in file
                                             ;
      st$tape_name: BYTARR(10),  $           ; 06- ???
      file_num: FIX(0),  $                   ; 16- The file number on the tape
      n_images: FIX(0),  $                   ; 18- Number of images within the tape file
                                             ;
      site: BYTE(0),  $                      ; 20- Observation site
                                             ;               Palehua
                                             ;               Learmonth
                                             ;               Holloman
                                             ;               Ramey
                                             ;               San Vito
      image_type: BYTE(0),  $                ; 21- h-alpha, magnesium b2, magnetogram
                                             ;
      noaa: FIX(0),  $                       ; 22- NOAA active region number
      location: INTARR(2),  $                ; 24- The location in heliocentric coordinates
                                             ;     Values are in degrees
                                             ;       (0) = E/W (E is negative)
                                             ;       (1) = N/S (S is negative)
                                             ;
      spare: BYTARR(4) }                     ; 28- Spare
   
   
   
GSN_ObsImage = { GSN_ObsImage_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
                                             ;
      image_num: FIX(0),  $                  ; 06- Image number within the file/block on
                                             ;     the archive tape
                                             ;
      fov_shape: BYTE(0),  $                 ; 08- code for size of fov
                                             ;       0 = full disk
                                             ;       1 = ?? x ?? arcsec
      resolution: BYTE(0),  $                ;  9- Image resolution (pixel size)
      seeing: BYTE(0),  $                    ; 10-
      spare: BYTARR(1) }                     ; 11-
   
   
   
GBO_Obs = { GBO_Obs_rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      duration: FIX(0),  $                   ; 06- Length of exposure in seconds
                                             ;
      st$site: BYTARR(1),  $                 ; 08- The site of the observation
                                             ;               ? = unknown
                                             ;               B = Big Bear
                                             ;               K = Kitt Peak
                                             ;               C = Boulder Colorado
                                             ;               H = Holloman (SOON)
                                             ;               L = Leamonth, Australia (SOON)
                                             ;               G = GSFC
                                             ;               P = Palehua (SOON)
                                             ;               R = Ramey (SOON)
                                             ;               S = San Vito (SOON)
                                             ;
                                             ;               N = NAOJ
                                             ;               J = CRL, Hiraiso
      st$image_type: BYTARR(2),  $           ;  9- The type of image
                                             ;       First Letter:
                                             ;               ? = unknown
                                             ;               H = H-alpha 
                                             ;               W = Continuum white
                                             ;               M = Magnetogram
                                             ;               I = Helium 10830 A
                                             ;               S = Spectrohelioscope 
                                             ;               X = X=ray
                                             ;       Second Letter:
                                             ;               TODO
      image_shape: BYTE(0),  $               ; 11- A coded value for the shape of the image
                                             ;       0 = unknown
                                             ;       1 = full disk
                                             ;       2 = large scale 
                                             ;
      processing: BYTE(0),  $                ; 12- A code about the processing done to the image
                                             ;       b0 - Set if came through SELSIS computer system
      telescope: BYTE(0),  $                 ; 13- The telescope used
                                             ;               0 = unknown
                                             ;       For BBSO
                                             ;               1 = 26"
                                             ;               2 = 5"
                                             ;
      seeing: BYTE(0),  $                    ; 14- Coded value on seeing quality
                                             ;       0 = unknown
                                             ;       1 = Very poor
                                             ;       2 = Poor
                                             ;       3 = Fair
                                             ;       4 = Good
                                             ;       5 = Excellent
      data_qual: BYTE(0),  $                 ; 15- Data quality
                                             ;       0 = unknown
                                             ;       1 = Severely compromised
                                             ;       2 = Compromised
                                             ;       3 = Average
                                             ;       4 = Better than average
                                             ;       5 = Excellent
                                             ;
      fov: INTARR(2),  $                     ; 16- The size of the FOV in arcseconds
      npix: INTARR(2),  $                    ; 20- The number of pixels 
                                             ;
      location: INTARR(2),  $                ; 24- The location in heliocentric coordinates
                                             ;     (not relevant for full disk images)
                                             ;     Values are in degrees
                                             ;       (0) = E/W (E is negative)
                                             ;       (1) = N/S (S i4~s negative)
      noaa: FIX(0),  $                       ; 28- NOAA active region number
      spare: BYTARR(2) }                     ; 30
   
   
   
BATSE_Event = { BATSE_Event_Rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      peak: LONG(0),  $                      ; 06- The number of seconds past the start time that the
                                             ;     peak intensity occurs
      duration: LONG(0),  $                  ; 10- The number of seconds that the event lasts
                                             ;
      event: FIX(0),  $                      ; 14- BATSE event number
      cnts_peak: FLOAT(0),  $                ; 16- Peak counts / sec / 2000 cm^2
      cnts_total: FLOAT(0),  $               ; 20- Total counts / 2000 cm^2
                                             ;
      bkg1_start: LONG(0),  $                ; 24- The number of seconds past the start time that the
                                             ;     first background was taken.
      bkg1_duration: LONG(0),  $             ; 28- The duration in seconds of the background period
      bkg2_start: LONG(0),  $                ; 32- The number of seconds past the start time that the
                                             ;     second background was taken.
      bkg2_duration: LONG(0),  $             ; 36- The duration in seconds of the background period
      spare: BYTARR(8) }                     ; 40- Spare
   
   
   
BATSE_LCur = { BATSE_LCur_Rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      channel1: FLOAT(0),  $                 ; 06- counts in channel 1 ?
      channel2: FLOAT(0),  $                 ; 10- counts in channel 2 ? (background?)
      spare: BYTARR(2) }                     ; 14- Spare
   
   
   
Nob_Event = { Nob_Event_Rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      duration: LONG(0),  $                  ; 06- The number of seconds that the event lasts
                                             ;
                                             ;         character*80  comments(8)     !- too much space
      spare: BYTARR(6) }                     ; 10- Spare
   
   
   
Nob_TimSer = { Nob_TimSer_Rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      coeff: FLOAT(0) }                      ; 06- Correlation Coefficient
   
   
   
GBO_Version = { GBO_Version_Rec,              $
      GEV : FIX('A021'x),  $                 ;   - GOES event log
      NAR : FIX('A031'x),  $                 ;   - NOAA Active Region - slf, from A020 to A031
      GXT : FIX('A041'x),  $                 ;   - GOES XR Derived from Tektronic, slf, 23-sep-92
      GXD : FIX('A051'x),  $                 ;   - GOES XR Supplied Digital, slf 23-sep-92
                                             ;
      GBE : FIX('A061'x),  $                 ;   - BATSE event log
      GBL : FIX('A071'x),  $                 ;   - BATSE light curve data
                                             ;
                                             ;
      NEL : FIX('A081'x),  $                 ;   - Nobeyama event log
      GOL : FIX('A091'x),  $                 ;   - GBO Observing Log
      NTS : FIX('A0A1'x),  $                 ;   - Nobeyama time series
                                             ;
      GUF : FIX('A0B1'x),  $                 ;   - Ulysees Ephemeris File
      spare: BYTARR(14) }                    ;     (need for automatic conversion to IDL format)
   
   
   
Uly_FEM = { Uly_FEM_Rec,              $
      time: LONG(0),  $                      ; 00- Time (millisec of day)
      day: FIX(0),  $                        ; 04- Day (since 1-Jan-79)
      radius: FLOAT(0),  $                   ; radial distance in AU
      he_lat: FLOAT(0),  $                   ; extrapolated heliographic latitude from solar surface
      he_lon: FLOAT(0),  $                   ; extrapolated heliographic logitude
      pvelocity: FLOAT(0),  $                ; proton velocity
      spare: BYTARR(10) }                    ;
   
   
   
  
  
end
