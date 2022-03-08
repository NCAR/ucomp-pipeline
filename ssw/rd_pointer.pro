	pro rd_pointer, lun_filnam, pointer, recsize
;	----------------------------------------------------------
;+						19-July-91
;	NAME:
;		Rd_Pointer
;	PURPOSE:
;		Read and extract the pointer section from requested
;		file.
;	CALLING SEQUENCE:
;		Rd_Pointer, lun_filnam, pointer, recsize
;	INPUT:
;		lun_filnam	input file specification or the
;				unit number of an openned reformatted
;				file.
;	Output:
;		pointer a logical record containning the pointer
;			section. 
;		recsize	VMS record size			
;	History:
;		written by Mons Morrison, Fall 90.
;		12-Dec-91 (MDM) Changed to allow a vector of filenames
;-
;	----------------------------------------------------------
;
gen_struct
pointer0 = {pointer_rec}
;
n = n_elements(lun_filnam)
pointer = replicate(pointer0, n)
;
for i=0,n-1 do begin
    siz = size(lun_filnam)
    vtyp = siz(siz(0)+1)
    if (vtyp eq 7) then begin		;passed file name
	openr, lun, lun_filnam(i), /block, /get_lun
    end else begin
	lun = lun_filnam(i)
    end
    ;
    ibyt = 0
    rdwrt, 'R', lun, ibyt, 0, pointer0
    pointer(i) = pointer0

    if (vtyp eq 7) then free_lun, lun
end
;
recsize = pointer.vms_rec_size
;
end
