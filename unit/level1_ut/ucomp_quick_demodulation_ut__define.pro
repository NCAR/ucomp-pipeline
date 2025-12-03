; docformat = 'rst'

function ucomp_quick_demodulation_ut::test_basic, output=output
  compile_opt strictarr

  xsize = 100   ; 1280
  ysize = 100   ; 1024
  n_extensions = 10
  data = randomu(seed, xsize, ysize, 4, 2, n_extensions)
  dmatrix = randomu(seed, 4, 4)

  t0 = systime(/seconds)
  standard = data * 0.0
  dims = size(data, /dimensions)
  for x = 0L, dims[0] - 1L do begin
    for y = 0L, dims[1] - 1L do begin
      for c = 0L, dims[3] - 1L do begin
        for e = 0L, dims[4] - 1L do begin
          standard[x, y, *, c, e] = dmatrix ## reform(data[x, y, *, c, e])
        endfor
      endfor
    endfor
  endfor
  t1 = systime(/seconds)
  result = ucomp_quick_demodulation(dmatrix, data)
  t2 = systime(/seconds)
  output = string(t1 - t0, t2 - t1, (t1 - t0) / (t2 - t1), $
                  format='(%"%0.1fs vs %0.1fs, %0.1fx")')

  threshold = 0.0001
  assert, total(abs(result - standard) gt threshold, /integer) eq 0L, $
          'results outside of threshold'

  return, 1
end


function ucomp_quick_demodulation_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  return, 1
end


pro ucomp_quick_demodulation_ut__define
  compile_opt strictarr

  define = {ucomp_quick_demodulation_ut, inherits UCoMPutTestCase}
end
