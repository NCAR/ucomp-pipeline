; main-level example program

n_iterations = 10L
norm = 2L^16  - 1.0
;im = dist(100)
;im = randomu(seed, 100, 100)
;im = fltarr(100, 100) + 100.0
im = rebin(reform(findgen(100), 100, 1), 100, 100)

im *= norm / max(im)

print, ucomp_roughness(im), format='initial image: roughness=%0.5f'
for i = 0L, n_iterations - 1L do begin
  im = smooth(im, 3, /edge_truncate)
  print, i + 1, ucomp_roughness(im), format='iteration %02d: roughness=%0.5f'
endfor

end
