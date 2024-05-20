; main-level example program

coeffs = randomu(seed, 3)
x = randomu(seed, 3)
x = x[sort(x)]
y = coeffs[0] + x * (coeffs[1] + x * coeffs[2])

xmin = ucomp_parabola(x, y)
xmin_standard = - coeffs[1] / (2.0 * coeffs[2])
print, xmin, xmin_standard, xmin - xmin_standard

n = 100
x_standard = findgen(n) / (n - 1)
y_standard = coeffs[0] + x_standard * (coeffs[1] + x_standard * coeffs[2])

plot, x, y, psym=4, xrange=[0.0, 1.0]
plots, fltarr(2) + xmin, !y.crange
plots, x_standard, y_standard, psym=3

end
