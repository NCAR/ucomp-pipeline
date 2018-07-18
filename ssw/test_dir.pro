;+
; Project     : HINODE/EIS
;
; Name        : TEST_DIR
;
; Purpose     : Test if a directory exists and is writeable
;
; Inputs      : DIR = directory name to test
;
; Keywords    : See WRITE_DIR
;
; Version     : Written, 12-Nov-2006, Zarro (ADNET/GFSC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function test_dir,dir,_ref_extra=extra

return,write_dir(dir,_extra=extra)

end
