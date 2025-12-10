; docformat = 'rst'

;+
; Read a master flat (or master dark-corrected flat) file to retrieve the center
; wavelength extensions.
;
; :Params:
;   filename : in, required, type=string
;     master flat filename
;
; :Keywords:
;   flats : out, optional, type="fltarr(1280, 1024, 2, n_center_wavelengths)"
;     set to a named variable to retrieve the flats with center wavelength,
;     normalized to 80 ms exposure time and NUMSUM=16
;   raw_filenames : out, optional, type=strarr(n_flats)
;     set to a named variable to retrieve the raw filename for each flat
;   wavelengths : out, optional, type=fltarr(n_flats)
;     set to a named variable to retrieve the wavelength for each flat
;   onband : out, optional, type=lonarr(n_flats)
;     set to a named variable to retrieve the onband value for each flat
;-
pro ucomp_read_master_flats, filename, $
                             flats=flats, $
                             raw_filenames=raw_filenames, $
                             onband=onband
  compile_opt strictarr

  n_index_extensions = 6L

  fits_open, filename, fcb

  fits_read, fcb, primary_data, primary_header, exten_no=0
  wave_region = ucomp_getpar(primary_header, 'FILTER')

  ; master flat file with extensions 1..n:
  ;   exts 1 to n - 5:   flat images
  ;   ext n - 5:         times of the flat images
  ;   ext n - 4:         exposure times of the flat images
  ;   ext n - 3:         wavelengths of the flat images
  ;   ext n - 2:         gain modes of the flat images
  ;   ext n - 1:         onbands of the flat images
  ;   ext n:             NUCs of the flat images

  n_flats = fcb.nextend - n_index_extensions
  nx = 1280L
  ny = 1024L
  flats = fltarr(nx, ny, 2, n_flats)
  raw_filenames = strarr(n_flats)
  numsum = lonarr(n_flats)
  onband = lonarr(n_flats)
  for e = 1L, n_flats do begin
    fits_read, fcb, data, header, exten_no=e
    flats[*, *, *, e - 1] = data * 16L   ; normalized to NUMSUM=16
    raw_filenames[e - 1] = ucomp_getpar(header, 'RAWFILE') 
  endfor

  fits_read, fcb, exptimes, header, exten_no=fcb.nextend - 4
  fits_read, fcb, wavelengths, header, exten_no=fcb.nextend - 3
  fits_read, fcb, onband, header, exten_no=fcb.nextend - 1

  fits_close, fcb

  flats *= 80.0 / rebin(reform(exptimes, 1, 1, 1, n_flats), nx, ny, 2, n_flats)   ; normalized to exposure time 80 ms

  ; return only information about center wavelength flats
  center_wavelength = ucomp_wave_region(float(wave_region), /central_wavelength)
  indices = where(abs(center_wavelength - wavelengths) lt 0.001)

  flats = flats[*, *, *, indices]

  raw_filenames = raw_filenames[indices]
  onband = onband[indices]
end


; main-level example program

; TODO: set filename

ucomp_read_master_flats, filename, $
                         flats=master_flats, $
                         raw_filenames=raw_filenames, $
                         onband=onband

end
