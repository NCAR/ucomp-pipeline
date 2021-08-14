; docformat = 'rst'

;+
; Evaluate the sum of a gaussian and a 2nd order polynomial and optionally
; return the value of its partial derivatives. Normally, this function is used
; by `MLSO_CURVEFIT` to fit the sum of a line and a varying background to actual
; data.
;
; The function is the form::
;
;   f = a[0] * exp(- ((x - a[1]) / a[2])^2 / 2) + a[3] + a[4] * x + a[5] * x^2
;
; Elements beyond `a[2]` are optional.
;
; :Params:
;   x : in, required
;     values of independent variable
;   a : in, required
;     parameters of equation described below
;   f : out
;     value of function at each `x[i]`
;   pder : out, optional, type=fltarr(n_x, 6)
;     array containing the partial derivatives::
;
;       pder[i, j] = derivative at point i wrt parameter j
;
; :Author:
;   MLSO Software Team
;
; :History:
;   Written by DMS, RSI, SEPT, 1982.
;   Modified by DMS, Oct 1990.  Avoids divide by 0 if A(2) is 0.
;   Added to GAUSS_FIT, when the variable function name to CURVE_FIT was
;     implemented. DMS, Nov, 1990.
;   CT, RSI, Dec 2003: Return correct array size if A[2] is 0.
;   CT, VIS, Oct 2013: Make sure the returned Gaussian width is positive.
;-
pro mlso_gauss_funct, x, a, f, pder
  compile_opt idl2, hidden
  on_error, 2

  n = n_elements(a)
  nx = n_elements(x)

  if (a[2] ne 0.0) then begin
    a[2] = abs(a[2])
    Z = (x - a[1]) / a[2]
    ez = exp(- z^2 / 2.0)
  endif else begin
    z = replicate(fix(100, type=size(x, /type)), nx)
    ez = z * 0
  endelse

  case n of
    3: f = a[0] * ez
    4: f = a[0] * ez + a[3]
    5: f = a[0] * ez + a[3] + a[4] * x
    6: f = a[0] * ez + a[3] + a[4] * x + a[5] * x^2
  endcase

  if (n_params() le 3) then return

  ; compute partial derivatives
  pder = fltarr(nx, n)
  pder[*, 0] = ez
  if (a[2] ne 0.0) then pder[*, 1] = a[0] * ez * z / a[2]
  pder[*,2] = pder[*, 1] * z
  if (n gt 3) then pder[*, 3] = 1.0
  if (n gt 4) then pder[*, 4] = x
  if (n gt 5) then pder[*, 5] = x^2
end



;+
; Fit the equation y = f(x) where::
;
;       f(x) = a0 * exp(- ((x - a1) / a2)^2 / 2) + a3 + a4 * x + a5 * x^2
;
; Terms a3, a4, and a5 are optional. The parameters a0, a1, a2, a3 are estimated
; and then `CURVEFIT` is called.
;
; The peak or minimum of the Gaussian must be the largest or smallest point in
; the Y vector.
;
; The initial estimates are either calculated by the below procedure or passed
; in by the caller. Then the function `CURVEFIT` is called to find the
; least-square fit of the gaussian to the data.
;
; Initial estimate calculation:
;   * If `nterms` > = 4 then a constant term is subtracted first.
;   * If `nterms` >= 5 then a linear term is subtracted first.
;   * If the (max - avg) of `y` is larger than (avg - min) then it is assumed
;     that the line is an emission line, otherwise it is assumed there is an
;     absorbtion line. The estimated center is the max or min element. The
;     height is (max - avg) or (avg - min) respectively. The width is found by
;     searching out from the extrema until a point is found less than the 1/e
;     value.
;
; :Returns:
;   the fitted function is returned
;
; :Params:
;   x : in, required, type=fltarr(n)
;     The independent variable, `x` must be a vector.
;   y : in, required, type=fltarr(n)
;     The dependent variable, `y` must have the same number of points as `x`.
;   a : out, optional, type=fltarr(nterms)
;     The coefficients of the fit, `a` is a 3-6 element vector as described above.
;
; :Keywords:
;   chisq : out, optional, type=float
;     set this keyword to a named variable that will contain the value of the
;     chi-square goodness-of-fit
;   estimates : in, optional, type=fltarr(nterms)
;     optional starting estimates for the parameters of the equation; should
;     contain `nterms` (6 if `nterms` is not provided) elements
;   measure_errors :
;     set this keyword to a vector containing standard measurement errors for
;     each point `y[i]`; this vector must be the same length as `x` and `y`
;
;     Note: for Gaussian errors (e.g. instrumental uncertainties),
;     `measure_errors` should be set to the standard deviations of each point in
;     `y`. For Poisson or statistical weighting `measure_errors` should be set
;     to `sqrt(y)`.
;   nterms : in, optional, type=integer, default=6
;     set `nterms` to 3 to compute the fit: f(x) = a0 * exp(- z^2/2)
;     set it to 4 to fit:  f(x) = a0 * exp(-z^2/2) + a3
;     set it to 5 to fit:  f(x) = a0 * exp(-z^2/2) + a3 + a4*x
;   sigma : out, optional, type=fltarr(n)
;     set this keyword to a named variable that will contain the 1-sigma error
;     estimates of the returned parameters
;
;     Note: if `measure_errors` is omitted, then you are assuming that
;     your model is correct. In this case, `sigma` is multiplied by
;     sqrt(chisq / (n - m)), where `n` is the number of points in `x` and `m` is
;     the number of terms in the fitting function. See section 15.2 of Numerical
;     Recipes in C (2nd ed) for details.
;   yerror : out, optional, type=fltarr(n)
;     set to a named variable to retrieve the standard error between `yfit` and
;     `y`
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the fit: 0 for success,
;     1 for chi-squared increasing without bound, and 2 for failed to converge
;   iter : out, optional, type=integer
;     set to a named variable to retrieve the number of iterations performed
;
; :Author:
;   MLSO Software Team
;
; :History:
;   DMS, RSI, Dec, 1983.
;   DMS, RSI, Jun, 1995, Added NTERMS keyword.  Result is now float if
;               Y is not double.
;   DMS, RSI, Added ESTIMATES keyword.
;   CT, RSI, Feb 2001: Change the way estimates are computed.
;         If NTERMS>3 then a polynomial of degree NTERMS-4 is subtracted
;         before estimating Gaussian coefficients.
;   CT, RSI, Nov 2001: Slight change to above modification:
;         Because a Gaussian and a quadratic can be highly correlated,
;         do not subtract off the quadratic term,
;         only the constant and linear terms.
;         Also added CHISQ, SIGMA and YERROR output keywords.
;   CT, RSI, May 2003: Added MEASURE_ERRORS keyword.
;   CT, RSI, March 2004: If estimate[2] is zero, compute a default value.
;   CT, VIS, Sept 2008: Do all computations in double precision,
;       convert back to single precision if inputs were single precision.
;-
function mlso_gaussfit, xIn, yIn, a, $
                        chisq=chisq, $
                        estimates=est, $
                        measure_errors=measureErrors, $
                        nterms=nt, $
                        sigma=sigma, $
                        yerror=yerror, $
                        status=status, $
                        iter=iter
  compile_opt idl2
  on_error, 2

  if (n_elements(nt) eq 0L) then nt = 6
  if (nt lt 3 or nt gt 6) then message, 'NTERMS must have values from 3 to 6.'
  n = n_elements(yIn)

  nMeas = n_elements(measureErrors)
  if ((nMeas gt 0) && (nMeas ne n)) then begin
    message, 'MEASURE_ERRORS must be a vector of the same length as Y'
  endif

  nEst = n_elements(est)
  if (nEst && nEst ne nt) then begin
    message, 'ESTIMATES must have NTERM elements.'
  endif

  isDouble = size(xIn, /type) eq 5 || size(yIn, /type) eq 5

  x = double(xIn)
  y = double(yIn)

  if (nEst eq 0 || est[2] eq 0) then begin   ; compute estimates?
    if (nt gt 3) then begin
      ; For a Gaussian + polynomial, we need to subtract off either a constant
      ; or a straight line to get good estimates. NOTE: Because a Gaussian and a
      ; quadratic can be highly correlated, we do not want to subtract off the
      ; quadratic term.
      c = poly_fit(x, y, (nt eq 4) ? 0 : 1, yf)
      yd = y - yf
    endif else begin
      ; Just fitting a Gaussian. Don't need to subtract off anything.
      yd = y
      c = 0d
    endelse

    ; x, y and subscript of extrema
    ymax = max(yd, imax)
    xmax = x[imax]
    ymin = min(yd, imin)
    xmin = x[imin]
    i0 = abs(ymax) gt abs(ymin) ? imax : imin   ; emiss or absorp?
    i0 = i0 > 1 < (n - 2)                       ; never take edges
    dy = yd[i0]                                 ; diff between extreme and mean
    del = dy / exp(1.0)                         ; 1/e value
    i = 0
    while ((i0 + i + 1) lt n) and $   ; guess at 1/2 width
           ((i0 - i) gt 0) and $
           (abs(yd[i0 + i]) gt abs(del)) and $
           (abs(yd[i0 - i]) gt abs(del)) do ++i
    a = [yd[i0], x[i0], abs(x[i0] - x[i0 + i])]
    if (nt gt 3) then a = [a, c[0]]     ; estimate for constant term
    if (nt gt 4) then a = [a, c[1]]     ; estimate for linear term
    if (nt gt 5) then a = [a, 0.0]      ; assume zero for quadratic estimate
  endif

  ; were estimates provided?
  if (nEst gt 0) then begin
    tmp = est
    ; did we need to compute the a2 term above?
    if (est[2] eq 0) then tmp[2] = a[2]
    a = tmp
  endif

  ; Convert from MEASURE_ERRORS to CURVEFIT weights argument. If we don't have
  ; MEASURE_ERRORS we will pass in an undefined variable to CURVEFIT, which will
  ; then assume no weighting.
  if (nMeas gt 0) then weights = 1 / measureErrors^2

  yfit = curvefit(x, y, weights, a, sigma, $
                  chisq=chisq, yerror=yerror, status=status, iter=iter, $
                  function_name='mlso_gauss_funct')

  if (~isDouble) then begin
    yfit = float(yfit)
    chisq = float(chisq)
    sigma = float(sigma)
    a = float(a)
  endif

  return, yfit
end
