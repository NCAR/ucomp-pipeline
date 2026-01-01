; docformat = 'rst'

;+
; Read a file containing metadata fixes data.
;
; The format is::
;
;   l0_filename, extension, hardware_name, value
;
; For example::
;
;   20220221.180817.95.ucomp.637.l0.fts,1,occulter,in
;
; :Returns:
;   array of structures of the form::
;
;     {filename: '', extension: 0L, keyword_name: '', keyword_value: ''}
;
;  `!null` if file is empty. `keyword_name` and `keyword_value` refer to the
;  FITS keyword name and value.
;
; :Params:
;   filename : in, required, type=string
;     full path to file containing metadata fixes data
;
; :Keywords:
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status of reading the file;
;     0 for no error
;-
function ucomp_read_metadata_fixes, filename, error=error
  compile_opt strictarr

  error = 0
  catch, error
  if (error ne 0) then begin
    catch, /cancel
    return, !null
  endif

  raw_metadata_fixes = read_csv(filename, count=n_metadata_fixes)
  if (n_metadata_fixes eq 0L) then return, !null

  metadata_fixes = replicate({filename: '', $
                              extension: 0L, $
                              keyword_name: '', $
                              keyword_value: ''}, $
                             n_metadata_fixes)

  metadata_fixes.filename      = raw_metadata_fixes.(0)
  metadata_fixes.extension     = raw_metadata_fixes.(1)
  metadata_fixes.keyword_value = raw_metadata_fixes.(3)

  keyword_name  = raw_metadata_fixes.(2)
  for f = 0L, n_metadata_fixes - 1L do begin
    ; occulter -> OCCLTR
    case keyword_name[f] of
      'occulter': keyword_name[f] = 'OCCLTR'
    endcase
  endfor
  metadata_fixes.keyword_name = keyword_name

  return, metadata_fixes
end
