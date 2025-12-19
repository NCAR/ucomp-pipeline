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
;   backgrounds : out, type="fltarr(nx, ny, ..., n_exts)"
;     background images
;   background_headers : in, optional, type=list
;     extension headers for background as list of `strarr`
;
; :Keywords:
;   step_number : in, required, type=integer
;     number of step in the level 1 processing of a file
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_intermediate_file, name, file, $
                                   primary_header, $
                                   data, headers, $
                                   backgrounds, background_headers, $
                                   step_number=step_number, run=run
  compile_opt strictarr

  if (run->config('intermediate/after_' + name)) then begin
    intermediate_dirname = filepath(string(step_number, name, format='(%"%02d-%s")'), $
                                    subdir=[run.date, 'level1'], $
                                    root=run->config('processing/basedir'))
    file->getProperty, l1_basename=basename, intermediate_name=name
    filename = filepath(basename, root=intermediate_dirname)
    if (~file_test(intermediate_dirname, /directory)) then file_mkdir, intermediate_dirname
    ucomp_write_fits_file, filename, $
                           primary_header, $
                           data, headers, $
                           backgrounds, background_headers, $
                           logger_name=run.logger_name
  endif
end
