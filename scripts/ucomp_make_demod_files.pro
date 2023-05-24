; docformat = 'rst'

pro ucomp_make_demod_files, filename, wave_regions, version
  compile_opt strictarr
  on_error, 2

  if (n_params() ne 3L) then message, 'missing argument: 3 required params'

  restore, filename
  dims = size(dmx_coefs, /dimensions)
  all_dmx_coeffs = dmx_coefs

  n_wave_regions = n_elements(wave_regions)
  if (dims[2] ne n_wave_regions) then begin
    message, string(n_wave_regions, dims[2], $
                    format='number of passed wave regions (%d) does not match number in file (%d)')
  endif

  for w = 0L, n_wave_regions - 1L do begin
    wave_region_filename = string(wave_regions[w], version, $
                                  format='ucomp.%s.dmx-temp-coeffs.%d.sav')
    dmx_coeffs = reform(all_dmx_coeffs[*, *, w, *])
    print, wave_region_filename, format='writing %s...'
    save, dmx_coeffs, filename=wave_region_filename
  endfor
end

; main-level example

basename = 'Dmx_Temp_Coefs.sav'
filename = filepath(basename, subdir=['..', 'resource', 'demodulation'], root=mg_src_root())
wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', $
                '802', '991', '1074', '1079', '1083']
ucomp_make_demod_files, filename, wave_regions, 1

end
