;+
; Project     : SOHO - CDS     
;                   
; Name        : CONCAT_DIR
;               
; Purpose     : To concatenate directory and file names for current os.
;               
; Explanation : The given file name is appended to the given directory
;               name with the format appropriate to the current operating
;               system. Can be also used to append two directory names
;               
; Use         : IDL> full_name = concat_dir(directory,filename)
;               IDL> pixfile = concat_dir('$DIR_GIS_MODEL','pixels.dat')
;
;               IDL> file = ['f1.dat','f2.dat','f3.dat']
;               IDL> dir = '$DIR_NIS_CAL'
;               IDL> f = concat_dir(dir,file)
;
; Inputs      : DIRECTORY           the directory path (string)
;               FILE                the basic file name and extension (string)
;                                   can be an array of filenames or directory
;                                   names
;
; Opt. Inputs : None
;               
; Outputs     : The function returns the concatenated string.  If the file 
;               input is a string array then the output will be a string 
;               array also.
;               
; Keywords    : DIR -- If set, the second argument is treated as a directory
;                      name instead of a file name (it has no effect if not
;                      under VMS system)
;               CHECK -- Check the validity of directory name(s) if set
;
; Calls       : CHK_DIR, BELL, BREAK_PATH
;               
; Restrictions: Assumes Unix type format if os is not VMS.
;               
; Side effects: None
;               
; Category    : Utilities, Strings
;               
; Prev. Hist. : Yohkoh routine by M. Morrison
;
; Written     : CDS version by C D Pike, RAL, 19/3/93
;               
; Modified    : 
;       Version 2, Liyun Wang, GSFC/ARC, January 3, 1995
;          Made it capable of concatenating directory names
;          Added keywords CHECK and DIR for output
;	Version 3, William Thompson, GSFC, 3 May 1995
;		Modified so spurious $ characters in front of VMS logical names
;		are ignored.  This makes it easier to port software written for
;		Unix to VMS.
;
; VERSION:
;       Version 2, January 3, 1995
;-            
;
FUNCTION concat_dir, dirname, filnam, check=check, dir=dir
;
;  Check number of parameters
;
   IF N_PARAMS() LT 2 THEN BEGIN
      PRINT,' ' & bell
      PRINT,'Use:   out_string = concat_dir( directory, filename)'
      PRINT,' ' 
      RETURN,''
   ENDIF
;
;  remove leading/trailing blanks
;
   dir0 = STRTRIM(dirname, 2)
   n_dir = N_ELEMENTS(dir0)
   IF N_ELEMENTS(check) EQ 0 THEN check = 0 ELSE check = 1 
;
;  act according to operating system
;
   IF (!version.os EQ 'vms') THEN BEGIN
      i = 0
      while i lt n_dir DO BEGIN
;
;  Call BREAK_PATH to make sure that a leading dollar sign is not a problem.
;  If more than one directory is returned, then only use the first one.  (Note
;  that the first entry in the array returned by break_path is always the null
;  path.
;
	 dir0(i) = (break_path(dir0(i)))(1)
;
         IF check THEN BEGIN
            IF NOT chk_dir(dir0(i)) THEN MESSAGE,/cont,$
                  'Warning: directory '+dir0(i)+' does not exist'
         ENDIF
         last = STRMID(dir0(i), STRLEN(dir0(i))-1,1)
         IF ((last NE ']') AND (last NE ':')) THEN BEGIN 
            dir0(i) = dir0(i) + ':' ;append an ending ':'
         ENDIF
	 i = i + 1
      ENDwhile

   ENDIF ELSE IF !version.os EQ 'windows' THEN BEGIN
      FOR i = 0, n_dir-1 DO BEGIN
         IF check THEN BEGIN
            IF NOT chk_dir(dir0(i)) THEN MESSAGE,/cont,$
                  'Warning: directory '+dir0(i)+' does not exist'
         ENDIF
         last = STRMID(dir0(i), STRLEN(dir0(i))-1, 1)
         IF (last NE '\') AND (last NE ':') THEN BEGIN
            dir0(i) = dir0(i) + '\' ;append an ending '\' 
         ENDIF
      ENDFOR

   ENDIF ELSE BEGIN
      FOR i = 0, n_dir-1 DO BEGIN
         IF check THEN BEGIN
            IF NOT chk_dir(dir0(i)) THEN MESSAGE,/cont,$
                  'Warning: directory '+dir0(i)+' does not exist'
         ENDIF
         IF (STRMID(dir0(i), STRLEN(dir0(i))-1, 1) NE '/') THEN BEGIN
            dir0(i) = dir0(i) + '/' ;append an ending '/' 
         ENDIF
      ENDFOR
   ENDELSE
;
;  no '/' needed when using default directory
;
   FOR i = 0, n_dir-1 DO BEGIN
      IF (dirname(i) EQ '') THEN dir0(i) = ''
   ENDFOR

;----------------------------------------------------------------------
;  Under Unix and Windows, FILNAM can still be appended to dir0 even if it 
;  is a directory name. Under VMS, however, we have to check to see if 
;  FILNAM is a directory name, and if it is, we have to do more to append
;  it to dir0.
;----------------------------------------------------------------------
   IF !version.os EQ 'vms' AND KEYWORD_SET(dir) THEN BEGIN
      dirlen = STRLEN(dir0(0))
      IF STRMID(dir0(0), dirlen-1,1) EQ ':' THEN BEGIN
;----------------------------------------------------------------------
;         dir0(0) is a logical dir name; we need to get its real name
;----------------------------------------------------------------------
         realdir = chklog(dir0(0))
         IF realdir EQ '' THEN $
            MESSAGE, dir0(0)+' is not a directory!'
      ENDIF ELSE realdir = dir0(0)
      temp = STRMID(realdir,0,STRLEN(realdir)-1)+'.'
      FOR i = 0, N_ELEMENTS(filnam)-1 DO BEGIN
         new_name = temp+STRUPCASE(filnam(i))+']'
         IF check THEN BEGIN
            IF chk_dir(new_name,outdir,/full) THEN BEGIN
               IF N_ELEMENTS(result) EQ 0 THEN $
                  result = outdir $
               ELSE $
                  result = [result, outdir]
            ENDIF ELSE $
	       message, 'Warning: '+new_name+' is not a valid directory name!',$
	          /continue
         ENDIF ELSE BEGIN
            IF N_ELEMENTS(result) EQ 0 THEN $
               result = new_name $
            ELSE $
               result = [result, new_name]
         ENDELSE
      ENDFOR
      IF N_ELEMENTS (result) NE 0 THEN RETURN, result ELSE RETURN, ''
   ENDIF ELSE RETURN, dir0 + filnam
END
