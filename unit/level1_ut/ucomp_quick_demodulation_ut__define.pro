; docformat = 'rst'

function ucomp_quick_demodulation_ut::test_basic
  compile_opt strictarr

  data = randomu(seed, 1280, 1024, 4, 2, 10)
  dmatrix = randomu(seed, 4, 4)

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

  result = ucomp_quick_demodulation(dmatrix, data)

  threshold = 0.0001
  assert, total(abs(result - standard) gt threshold, /integer) eq 0L, $
          'results outside of threshold'

  return, 1
end


function ucomp_quick_demodulation_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  return, 1
end


pro ucomp_quick_demodulation_ut__define
  compile_opt strictarr

  define = {ucomp_quick_demodulation_ut, inherits MGutTestCase}
end
