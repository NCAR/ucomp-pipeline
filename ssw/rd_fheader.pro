        PRO rd_fheader, lun_filnam, file_header, ndset
;       ----------------------------------------------------------
;+                                              23-July-91
;       NAME:
;               Rd_fHeader
;       PURPOSE:
;               Read and extract the file header section from
;               requested file.
;       CALLING SEQUENCE:
;               Rd_fHeader, lun_filnam, file_header, ndset
;       INPUT:
;               lun_filnam      input file specification or the
;                               unit number of an openned reformatted
;                               file.
;       Output:
;               file_header     a logical record containning the
;                               standard file header section.
;               ndset           number of data sets contained within
;                               the file (number of logical roadmap
;                               records).
;       History:
;               written by Mons Morrison, Fall 90.
;		12-Dec-91 (MDM) Changed to allow a vector of filenames
;		25-May-01 (LWA) Made variable in "for" call a longword
;-
;	----------------------------------------------------------
;
gen_struct
file_header0 = {file_header_rec}
;
n = n_elements(lun_filnam)
file_header = replicate(file_header0, n)
;
for i=0L,n-1 do begin
    siz = size(lun_filnam)
    vtyp = siz(siz(0)+1)
    if (vtyp eq 7) then begin		;passed file name
	openr, lun, lun_filnam(i), /block, /get_lun
    end else begin
	lun = lun_filnam(i)
    end
    ;
    rd_pointer, lun, pointer
    ibyt = pointer.file_header
    rdwrt, 'R', lun, ibyt, 0, file_header0
    file_header(i) = file_header0

    if (vtyp eq 7) then free_lun, lun
end
;
ndset = file_header.nDataSets
;
end
