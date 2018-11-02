; docformat = 'rst'

;+
; Generate a random synthetic L0 file.
;
; :Params:
;   filename : in, required, type=string
;     filename of generated L0 file
;-
pro ucomp_generate_l0, filename
  compile_opt strictarr

  wavelengths = [1074.38, 1074.50, 1074.62, 1074.74, 1074.86]

  primary_hash = ucomp_generate_primary_header()
  primary_header_template = filepath('ucomp_l0_primary_header.tt', root=mg_src_root())
  primary_data = 0.0
  primary_header = ucomp_make_header(primary_header_template, $
                                     primary_data, $
                                     primary_hash, $
                                     /extend)

  fits_open, filename, fcb, /write
  fits_write, fcb, primary_data, primary_header

  extension_hash = ucomp_generate_extension_header()

  for w = 0L, n_elements(wavelengths) - 1L do begin
    extension_hash['wavelength'] = wavelengths[w]
    extension_header_template = filepath('ucomp_l0_extension_header.tt', root=mg_src_root())

    extension_data = randomu(seed, 1280, 1024, 4, 2)
    extension_header = ucomp_make_header(extension_header_template, $
                                         extension_data, $
                                         extension_hash, $
                                         /image)


    fits_write, fcb, extension_data, extension_header, $
                extname=string(extension_hash['wavelength'], format='(%"%0.2f")')
  endfor

  fits_close, fcb
  obj_destroy, [primary_hash, extension_hash]
end


; main-level example program

ucomp_generate_l0, '20181102.020900.ucomp.fts'

end
