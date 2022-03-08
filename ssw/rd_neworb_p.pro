	pro rd_neworb_p, fileNa, neworb_p, newOrb_Hd
;+
;	Name:
;		Rd_NewOrb_p
;	History:
;		written by MDM March-91
;-
obs_struct
;
get_lun, lun
openr, lun, fileNa, /block
;
rd_pointer, lun, pointer, recsize
rd_fheader, lun, fheader, ndset
;
ibyt = pointer.opt_section
NewOrb_Hd = {Obs2_NewOrb_Hd_Rec}
rdwrt, 'R', lun, ibyt, 0, NewOrb_Hd, 1
;
nOrbitRec = NewOrb_Hd.nOrbitRec		;number of orbit rec entries
;
case neworb_hd.neworbit_ver of
    1: obs_struct, obs2_neworbit=data_ref
    else: obs_struct, obs_neworbit=data_ref		;original case (value = 0)
endcase
;
neworb_p = replicate(data_ref, nOrbitRec)
rdwrt, 'R', lun, ibyt, 0, neworb_p
;
free_lun, lun
end
