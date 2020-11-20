; docformat = 'rst'

;+
; Loads the given color table.
;
; :Params:
;   name : in, required, type=string
;     name of color table to load: b/w
;
; :Keywords:
;   n_colors : in, optional, type=integer
;     number of colors needed, defaults to 256
;   rgb : out, optional, type="bytarr(256, 3)"
;     set to a named variable to retrieve the color table values
;-
pro ucomp_loadct, name, n_colors=n_colors, rgb=rgb
  compile_opt strictarr

  case strlowcase(name) of
    'b/w': begin
        loadct, 0, /silent, ncolors=n_colors
        if (arg_present(rgb)) then tvlct, rgb, /get
      end
  endcase
end
