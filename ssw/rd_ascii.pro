;+
; Project     : SOHO - CDS
;
; Name        : RD_ASCII
;
; Purpose     : Read sequential ASCII file
;
; Explanation : Reads an ASCII file and returns as a text array.
;
;               It is possible to read parts of a file by specifying the
;               first and last line numbers through the keyword LINES,
;               e.g.:
;
;               text = rd_ascii(file,lines=[1,10])
;
;               will read lines 1 through 10. Lines are numbered from 1 and
;               up. To read only one line, set LINES to the line number.
;
;               This routine uses an internal buffer to speed up reading.
;               This is achieved by using READU instead of READF, and by
;               avoiding memory copying of large text array by allocating the
;               whole text array once.  This results in a quite substantial
;               speedup, of course somewhat depending on the characteristics
;               of the given system.  In order to avoid too large internal
;               buffers, an upper limit on the block size can be specified.
;               The default is no -1, which means use a buffer the size of the
;               file.
;
;               If the file is larger than the block size, the routine reads
;               the file twice, in blocks of the specified size. On the first
;               pass, the lines are counted, and on the second pass, the lines
;               are stored in the allocated array.
;
; Use         : output = rd_ascii(file)
;
; Inputs      : file = string file name
;
; Outputs     : output = string array with ASCII text
;
; Keywords    : LINES : Set to a line number to read just one line.
;                       Set to a line number range, e.g., [1,N] to
;                       read lines 1 trough N.
;
;               BLOCKSIZE : Maximum buffer size. Default value -1, which
;                           means use a buffer the size of the file.
;                           No effect under VMS.
;
;               ERROR : Set to a named variable that will be zero if no
;                       error occurred, or 1 if an error did occur.
;
;               STREAM : If set, then force a VMS file to be read in stream.
;                        For internal use only, since it attempts to read all
;                        VMS files this way first.  An error condition results
;                        if this is set initially for a sequential file.
;
;               LUN    : LUN used in open (output)
;
; Restrictions: VMS: Due to a problem with variable length sequential files,
;               no internal buffer is used, so BLOCKSIZE has no effect on such
;               files.
;
;               Other than that, none known, but the algorithm used for
;               reading is rather complex. However, the routine reads all
;               *.pro files in the CDS path correctly for any buffer size, so
;               no obvious bugs should be present.
;
; Category    : I/O
;
; Written     : Version 1.0, DMZ (ARC) August 22 1994
;
; Modified    : Version 1.1, DMZ (ARC/GSFC) October 29 1994
;               Fixed potential bug in irec
;
;               Version 2, SVHH (UiO), 28 May 1996
;                       Switched to new algorithm with buffered reads,
;                       added LINES, ERROR and BLOCKSIZE keywords.
;               Version 3, SVHH (UiO), 21 June 1996
;                       VMS problem with variable length sequential files
;                       reported by Richard Schwartz. Inserted the old version
;                       of the routine as a VMS branch, but rearranged a
;                       little bit to use larger buffer (1000 lines) and
;                       to allow the LINES keyword to be used, although not in
;                       any efficient way (all text is read in and then
;                       truncated). This might be improved later.
;                       For non-VMS the default block size changed to -1 (use
;                       a buffer the size of the file).
;               Version 3.1, RAS (GSFC), 21 June 1996
;                       Added STREAM keyword and forced first VMS read to be
;                       STREAM.  If the VMS file is a stream file the
;                       LINES keyword is used efficiently since the readu
;                       path is in effect.  Made sure that closed and freed
;                       LUN on error.
;                       There is still room for improvement in the VMS
;                       sequential read on very large files, reading only the
;                       desired lines, I will leave that to the next motivated
;                       user.
;
;		Version 4, Richard.Schwartz@gsfc.nasa.gov, 18 August 1998.
;			Modify SEP_LEN variable under Windows if end of line sequence
;			does not include the normal carriage return, line feed terminators.
;
;               Version 5, Zarro (SM&A/GSFC), 15-Aug-99
;                       Added LUN as output keyword
;		Version 6, richard.schwartz@gsfc.nasa.gov, 11 July 2000.
;			Protect against -1 reference in b array under windows test.
;
;               Version 7, Zarro (EITI/GSFC) 7 Mar 2001
;                       Added call to free_lun and close before each
;                       return to ensure all opened files are closed
;
;               Version 8, Zarro (EITI/GSFC) 26 Apr 2001
;                       Added call to chklog, since RD_ASCII had
;                       problems reading filenames with embedded environment
;                       variables.
;               7-November-2013, Zarro (ADNET)
;                       - removed call to CHKLOG. Seems redundant now.
;-
;-------------------------------------------------------------------------
;-- utility procedure to call prior to each return

pro rd_ascii_free,lun

if n_elements(lun) ne 0 then begin
 free_lun,lun
 close,lun
endif

return & end

;----------------------------------------------------------------------------

FUNCTION rd_ascii,file,lines=lines,error=error,blocksize=iblocksize,  $
                  stream=stream,lun=lun

  sz=size(file)
  vtype=sz[n_elements(sz)-2]
  if vtype ne 7 then return,''

  cfile=file[0]
  if cfile eq '' then return,''

  default,iblocksize,-1         ; Use a buffer the same size as the file

  parcheck,cfile,1,typ(/str),0,'FILENAME'
  parcheck,iblocksize,0,typ(/rea),0,'BLOCKSIZE'
  IF N_ELEMENTS(lines) NE 0 THEN BEGIN
     parcheck,lines,0,typ(/rea),[0,1],'LINES'
  END

  ;; Default is no error occurred
  error=0

  ;;
  ;; Make sure lines has standard form
  ;;
  IF N_ELEMENTS(lines) EQ 1 THEN lines = [lines,lines]

  IF N_ELEMENTS(lines) EQ 2 THEN BEGIN

     ;; These are programmer errors, and shouldn't go unnoticed
     ;; by simply setting ERROR=1

     IF lines[0] LT 1 THEN $
        MESSAGE,"Lines should be numbered 1 and up"

     IF lines[1] LT lines[0] THEN  $
        MESSAGE,"Can't read backwards, lines[0]>lines[1]"
  END


  IF os_family() EQ 'vms' AND NOT KEYWORD_SET(stream) THEN BEGIN
     ;;
     ;; Check to see if it can be read successfully as a stream file!
     ;;
     test = rd_ascii(cfile,lines=lines,error=error,blocksize=blocksize,/stream)
     IF NOT error THEN begin rd_ascii_free,lun & RETURN, test & endif
     ON_ERROR,1

     line = ' '
     ilines = STRARR(1000)

     ;; If we don't reach the normal end, an error occurred
     error = 1

     ON_IOERROR,quit
     OPENR, lun, cfile, /GET_LUN
     fstat = fstat(lun)
     irec = -1
     WHILE fstat.cur_ptr LT fstat.size DO BEGIN
        irec = irec + 1
        IF (irec MOD 1000) EQ 0 THEN ilines = [ilines,STRARR(1000)]
        READF, lun, line
        IF (irec GT -1) AND (irec LT N_ELEMENTS(ilines)) THEN $
           ilines[irec] = line
        fstat = fstat(lun)
     ENDWHILE

     ;; Normal end
     error = 0

     quit: ON_IOERROR,ERROR_RETURN_BLANK

     IF N_ELEMENTS(lun) EQ 0 THEN GOTO,ERROR_RETURN_BLANK

     CLOSE,lun
     FREE_LUN, lun

     IF (irec GT -1) AND (irec LT N_ELEMENTS(ilines)) THEN $
        ilines = ilines[0:irec] ELSE ilines=''

     IF N_ELEMENTS(lines) EQ 0 THEN begin
      rd_ascii_free,lun
      RETURN,ilines
     endif

     ;; Make sure we stay within bounds
     lines[1] = lines[1] < N_ELEMENTS(ilines)

     rd_ascii_free,lun
     RETURN,ilines[lines[0]-1:lines[1]-1]
  END

  ;; Just return a blank on error.
  ON_IOERROR,ERROR_RETURN_BLANK

  ;; If the file doesn't exist, we'll signal an error
  OPENR,lun,cfile,/GET_LUN

  ;; Get stats
  fst = fstat(lun)

  blocksize = iblocksize
  IF blocksize EQ -1 THEN blocksize = fst.size

  IF fst.size EQ 0 THEN begin
   rd_ascii_free,lun
   RETURN,['']
  endif

  ;; Length of separators
  sep_len = 1

  ;; CR/LF for windows
  IF STRUPCASE(os_family()) EQ 'WINDOWS' THEN sep_len = 2

  IF blocksize EQ 0 OR fst.size LE blocksize THEN BEGIN
                                ; Process whole array
     b = bytarr(fst.size,/nozero)

     READU,lun,b
     CLOSE,lun
     FREE_LUN,lun

     ;; Find line separators (and add one at beginning)
     i = [-1L,WHERE(b EQ 10b,nlines)]
     ;; Check under Windows that sep_len is really two.
     IF STRUPCASE(os_family()) EQ 'WINDOWS' THEN $
	IF b[(i[1]-1>0)] NE 13b THEN sep_len = 1

     ;; One unbroken line. Will crash if size > 2^15-1
     IF nlines EQ 0 THEN  begin
        rd_ascii_free,lun
        RETURN,STRING(b)
     endif

     ;; Count the last line even if it's not terminated

     IF b[fst.size-1] NE 10b THEN BEGIN
        nlines = nlines+1L
        i = [i,fst.size+sep_len-1]
     END

     IF N_ELEMENTS(lines) EQ 0 THEN lines = [1L,nlines]

     first = lines[0]

     ;; We shouldn't encounter end-of-file with this precaution
     last = lines[1] < nlines
     nlines = (last-first+1)
     IF nlines LE 0 THEN GOTO,ERROR_RETURN_BLANK

     ;; Create the array
     arr = STRARR(nlines)

     ;; And read it
     FOR ii = first-1,last-1 DO BEGIN
        firsti = i[ii]+1        ; Skip previous LF
        lasti = i[ii+1]-sep_len ; Skip previous [CR] LF
        IF b[lasti > 0] EQ 13b THEN lasti = lasti-1 ; Skip CR anyhow
        IF lasti GE firsti THEN $ ; Watch out for empty lines
           arr[ii-first+1] = STRING(b[firsti:lasti])
     END

     rd_ascii_free,lun
     RETURN,arr
  END ELSE BEGIN

     ;; PRINT,"Using buffer, blocksize="+trim(blocksize)
     ;; This buffer is used throughout this section

     b = bytarr(blocksize)

     IF N_ELEMENTS(lines) EQ 0 THEN BEGIN
        ;; For reading very large files, we first count lines, and then
        ;; read it in once over.

        nlines = 0

        ;; Read all full blocks, count lines
        FOR ptr=0L,fst.size-blocksize,blocksize DO BEGIN
           READU,lun,b
           i = WHERE(b EQ 10b,blines) ; Find line terminators
     	;; Check under Windows that sep_len is really two on first pass.
     	   IF STRUPCASE(os_family()) EQ 'WINDOWS' AND ptr EQ 0 THEN $
		IF b[i[1]-1] NE 13b THEN sep_len = 1
           nlines = nlines + blines
        END

        ;; Read last, non-full, block
        IF ptr LT fst.size THEN BEGIN
           b[*] = 0b
           ON_IOERROR,READ_EOF  ; We *expect* an ioerror here!
           READU,LUN,B
           READ_EOF:
           ON_IOERROR,ERROR_RETURN_BLANK
           i = WHERE(b EQ 10b,blines)
           nlines = nlines + blines
           ;; Count the last line even if it's not terminated
           IF b[fst.size-ptr-1] NE 10b THEN nlines = nlines + 1
        END

        ;; Rewind the file and read all lines over
        point_lun,lun,0L
        lines = [1L,nlines]
        ;; PRINT,"Lines :",lines
     END

     ;; Lines

     start = lines[0]
     last = lines[1]

     nlines = lines[1]-lines[0]+1
     IF nlines LE 1 THEN GOTO,ERROR_RETURN_BLANK

     arr = STRARR(nlines)

     ;; Line number of 1st character in block,
     ;; or line no of next string to be processed in block
     lineno = 1L

     ;; True if previous line was truncated by block boundary
     truncated = 0b

     ;; Contains any truncated line being processed
     trunc = ''

     ;; This is a debugging feature - set to make the block read
     ;; stop at this line.
     stopatline = -1

     ;; Read all full blocks
     FOR ptr=0L,fst.size-blocksize,blocksize DO BEGIN
        READU,lun,b
        ;; Find line terminators
        i = WHERE(b EQ 10b,blines)
        IF blines EQ 0 THEN BEGIN
           ;; There's no end to this line!
           truncated = 1b
           lasti = blocksize-1
           IF b[lasti] EQ 13b THEN lasti = lasti-1
           IF lineno GE start THEN trunc = trunc + STRING(b[0:lasti])
        END ELSE BEGIN
           ;; If the first line that is terminated in this block line
           ;; was truncated by the last block boundary, what to do
           ;; with it?
           IF truncated THEN BEGIN
              blines = blines-1
              ;; Read it in if we're interested
              IF lineno GE start AND lineno LE last THEN BEGIN
                 firsti = 0
                 lasti = i[0]-sep_len
                 IF b[lasti > 0] EQ 13b THEN lasti = lasti-1 ; Skip CR anyhow
                 IF lasti GE firsti THEN  $ ; Watch out for empty line
                    arr[lineno-start] = trunc + STRING(b[firsti:lasti]) $
                 ELSE  $
                    arr[lineno-start] = trunc
              END

              ;; Count that line
              lineno = lineno+1
              IF lineno EQ stopatline THEN stop
              IF lineno GT last THEN GOTO,FINISHED_READING

              ;; We're no longer truncated.
              truncated = 0b
              trunc = ''
           END ELSE BEGIN
              ;; Add first line "starting" point
              i = [-1L,i]
           END

           ;; Add ending point for any *new* truncated line
           IF b[blocksize-1] NE 10b THEN BEGIN
              truncated = 1b
              i = [i,blocksize+sep_len-1]
           END

           ;; Blines is NOT adjusted for any new truncated line!!
           FOR ii = 0L,blines-1L DO BEGIN
              IF lineno GE start AND lineno LE last THEN BEGIN
                 firsti = i[ii]+1 ; Skip previous LF
                 lasti = i[ii+1]-sep_len ; Skip previous [CR] LF
                 IF b[lasti > 0] EQ 13b THEN lasti = lasti-1
                 IF lasti GE firsti THEN $ ; Watch out for empty lines
                    arr[lineno-start] = STRING(b[firsti:lasti])
              ENDIF
              lineno = lineno + 1
              IF lineno EQ stopatline THEN stop
              IF lineno GT last THEN GOTO,FINISHED_READING
           ENDFOR

           ;; In case blines-1L is -1, that blasted FOR loop will set
           ;; ii to 1 after *not* executing any iterations ???
           ii = ii < blines

           ;; That means we're dealing with the truncated line here.
           ;; The i(*) array has been modified to take the strain
           IF truncated THEN BEGIN
              IF lineno GE start AND lineno LE last THEN BEGIN
                 firsti = i[ii]+1
                 lasti = i[ii+1]-sep_len
                 IF b[lasti > 0] EQ 13b THEN lasti = lasti-1 ; Skip CR anyhow
                 IF lasti GE firsti THEN $ ; Empty ??
                    trunc = STRING(b[firsti:lasti])
              END
           END
        END
     END

     ;; Read last, non-full, block
     IF ptr LT fst.size THEN BEGIN
        b[*] = 0b
        ON_IOERROR,READ_EOF2    ; We *expect* an ioerror here!
        READU,LUN,B
        READ_EOF2:
        ON_IOERROR,ERROR_RETURN_BLANK
        i = WHERE(b EQ 10b,blines)

        blocksize = fst.size-ptr

        ;; There's NO MORE
        IF blines EQ 0 THEN BEGIN
           IF b[blocksize-1] EQ 13b THEN blocksize=blocksize-1
           IF lineno GE start AND lineno LE last THEN  $
              arr[lineno-start] = trunc + STRING(b[0:blocksize-1])
           GOTO,FINISHED_READING
        END

        IF truncated THEN BEGIN
           ;; The first one doesn't count
           blines = blines-1
           IF lineno GE start AND lineno LE last THEN BEGIN
              firsti = 0
              lasti = i[0]-sep_len
              IF b[lasti > 0] EQ 13b THEN lasti = lasti-1 ; Skip CR anyhow
              IF lasti GE firsti THEN $ ; Empty?
                 arr[lineno-start] = trunc + STRING(b[firsti:lasti]) $
              ELSE $
                 arr[lineno-start] = trunc ;; Don't throw away this!
           END
           lineno = lineno+1
           IF lineno EQ stopatline THEN stop
           IF lineno GT last THEN GOTO,finished_reading
           truncated = 0b
           trunc = ''
        END ELSE BEGIN
           ;; Add first line "starting" point
           i = [-1L,i]
        END

        ;; Add ending point for any *new* truncated line
        IF b[blocksize-1] NE 10b THEN BEGIN
           truncated = 1b
           i = [i,blocksize+sep_len-1]
           blines = blines+1
        END

        ;; Blines IS adjusted for the truncated line!!
        ;; So the last line is taken care of here
        FOR ii = 0L,blines-1L DO BEGIN
           IF lineno GE start AND lineno LE last THEN BEGIN
              firsti = i[ii]+1  ; Skip previous LF
              lasti = i[ii+1]-sep_len ; Skip previous [CR] LF
              IF b[lasti > 0] EQ 13b THEN lasti = lasti-1 ; Skip CR anyhow
              IF lasti GE firsti THEN $ ; Watch out for empty lines
                 arr[lineno-start] = STRING(b[firsti:lasti])
           ENDIF
           lineno = lineno + 1
           IF lineno EQ stopatline THEN stop
           IF lineno GT last THEN GOTO,FINISHED_READING
        ENDFOR

     END

     ;; If we  get here, there weren't as many lines in the file
     ;; as was asked for (but this is no error)
     arr = arr[0:[lineno-2] > 0]

     FINISHED_READING:
     ON_IOERROR,DONTCARE
     CLOSE,lun
     FREE_LUN,lun
     DONTCARE:
     rd_ascii_free,lun
     RETURN,arr
  END


  ERROR_RETURN_BLANK:
  IF N_ELEMENTS(lun) Ge 1 THEN BEGIN
     ON_IOERROR,ABORT
     CLOSE,lun
     FREE_LUN,lun
  END
  ABORT:
  ON_IOERROR,NULL
  error = 1
  rd_ascii_free,lun
  RETURN,['']
END
