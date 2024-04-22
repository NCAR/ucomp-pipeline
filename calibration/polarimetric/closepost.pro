pro closepost,answer
if answer ne 's' then begin
  device,/close
  set_plot,'X'
endif
!p.multi=0
end
