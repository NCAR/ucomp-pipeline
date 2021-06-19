; docformat = 'rst'

;+
; Write an intermediate FITS file if turned on in the config options.
;
; :Params:
;   name : in, required, type=string
;     name of the step of the level 1 processing after which to write the file,
;     i.e., "apply_gain", "demodulation", etc.
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     FITS primary header
;   data : in, required, type="fltarr(nx, ny, ..., n_extensions)"
;     data to write
;   headers : in, required, type=list
;     list of `strarr` FITS headers
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_intermediate_file, name, $
                                   file, primary_header, data, headers, $
                                   run=run
  compile_opt strictarr

  if (run->config('intermediate/after_' + name)) then begin
    l1_dirname = filepath('', $
                          subdir=[run.date, 'level1'], $
                          root=run->config('processing/basedir'))
    file->getProperty, l1_basename=basename, intermediate_name=name
    filename = filepath(basename, root=l1_dirname)
    ucomp_write_fits_file, filename, primary_header, data, headers
  endif
end
