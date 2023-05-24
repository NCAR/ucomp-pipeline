; docformat = 'rst'

;+
; Raises an error if the given condition is not met. Uses `logical_predicate`
; to determine truth of condition: so zero or null values are false, anything
; else is true. Be careful of conditions like the following::
;
;    ucomp_assert, not file_test(filename)
;
; This uses the bitwise `not` operator and therefore this assertion is
; always false.
;
; :Examples:
;    It is typical to check the error in a calculation like the following::
;
;       mg_assert, error gt tolerance, 'incorrect result, error = %f', error
;
; :Params:
;    condition : in, required, type=boolean
;       condition to assert
;    msg : in, optional, type=string, default="'Assertion failed'"
;       message to throw if condition is not met
;    arg1 : in, optional, type=string
;       argument for any C format codes in msg
;    arg2 : in, optional, type=string
;       argument for any C format codes in msg
;    arg3 : in, optional, type=string
;       argument for any C format codes in msg
;    arg4 : in, optional, type=string
;       argument for any C format codes in msg
;    arg5 : in, optional, type=string
;       argument for any C format codes in msg
;
; :Keywords:
;    from : in, optional, type=string
;       set to skip the current test instead of passing or failing
;-
pro ucomp_assert, condition, msg, arg1, arg2, arg3, arg4, arg5, from=from
  compile_opt strictarr, logical_predicate, hidden
  on_error, 2

  if (~condition) then begin
    default_msg = 'Assertion failed'
    case n_params() of
      0: return
      1: _msg = default_msg
      2: if (n_elements(msg) gt 0L) then _msg =msg else _msg = default_msg
      3: _msg = string(arg1, format='(%"' + msg + '")')
      4: _msg = string(arg1, arg2, format='(%"' + msg + '")')
      5: _msg = string(arg1, arg2, arg3, format='(%"' + msg + '")')
      6: _msg = string(arg1, arg2, arg3, arg4, format='(%"' + msg + '")')
      7: _msg = string(arg1, arg2, arg3, arg4, arg5, format='(%"' + msg + '")')
      8: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, format='(%"' + msg + '")')
      9: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, format='(%"' + msg + '")')
      10: _msg = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, format='(%"' + msg + '")')
    endcase

    if (n_elements(from) eq 0L) then begin
      message, _msg
    endif else begin
      message, string(strupcase(from), _msg, format='(%"%s: %s")'), /noname
    endelse
  endif
end
