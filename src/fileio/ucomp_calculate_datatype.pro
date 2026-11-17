; docformat = 'rst'

;+
; Determine DATATYPE value given the hardware positions in the header. See
; GitHub #367 for the decision tree used to determine DATATYPE.
;
; :Returns:
;   string: "flat", "dark", "cal", "sci", "eng", or "invalid"
;
; :Params:
;   header : in, required, type=strarr
;     extension header
;-
function ucomp_calculate_datatype, header
  compile_opt strictarr

  ; these are the hardware position keywords that must be present and can have
  ; value "in", "out", or "mid"
  hw_keywords = ['OCCLTR', 'CALOPTIC', 'COVER', 'DIFFUSR', 'DARKSHUT']
  n_hw_keywords = n_elements(hw_keywords)

  positions = strarr(n_hw_keywords)
  all_found = 1B
  for k = 0L, n_hw_keywords - 1L do begin
    value = ucomp_getpar(header, hw_keywords[k], found=found)
    positions[k] = mg_default(value, '')
    all_found and= found
    if (found) then positions[k] = strlowcase(positions[k]) else positions[k] = 'NA'
    if (positions[k] ne 'in' && positions[k] ne 'out') then return, 'invalid'
  endfor

  if (~all_found) then return, 'invalid'

  ; these are hardware position keywords that were added later and might not be
  ; present, they should still have values "in", "out", or "mid"
  extra_hw_keywords = ['O1ND', 'GRID']
  n_extra_hw_keywords = n_elements(extra_hw_keywords)
  extra_positions = strarr(n_extra_hw_keywords)
  for k = 0L, n_extra_hw_keywords - 1L do begin
    value = ucomp_getpar(header, extra_hw_keywords[k], found=found)
    extra_positions[k] = mg_default(value, '')
    if (found) then begin
      extra_positions[k] = strlowcase(extra_positions[k])
      if (extra_positions[k] ne 'in' && extra_positions[k] ne 'out') then begin
        return, 'invalid'
      endif
    endif else extra_positions[k] = 'NA'
  endfor

  !null = where((extra_positions ne 'in') and (extra_positions ne 'NA'), n_not_in)
  if (n_not_in gt 0L) then return, 'eng'

  if (positions[where(hw_keywords eq 'DARKSHUT')] eq 'in') then return, 'dark'

  if (positions[where(hw_keywords eq 'COVER')] eq 'in') then return, 'eng'

  if (positions[where(hw_keywords eq 'DIFFUSR')] eq 'in' $
        && positions[where(hw_keywords eq 'CALOPTIC')] eq 'in') then begin
    return, 'cal'
  endif

  if (positions[where(hw_keywords eq 'DIFFUSR')] eq 'in') then return, 'flat'

  if (positions[where(hw_keywords eq 'OCCLTR')] eq 'in') then begin
    out_indices = where(positions eq 'out', n_out)
    if (n_out eq (n_hw_keywords - 1)) then return, 'sci'
  endif

  return, 'eng'
end

