#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#ifdef strlcpy
#undef strlcpy
#endif

#ifdef strlcat
#undef strlcat
#endif

#include "idl_export.h"

static IDL_VPTR IDL_ucomp_quick_distortion(int argc, IDL_VPTR *argv) {
  //IDL_VPTR x, IDL_VPTR dx1_c, IDL_VPTR dy1_c, IDL_VPTR dx2_c, IDL_VPTR dy2_c)
  IDL_VPTR x = argv[0];
  IDL_VPTR dx1_c = argv[1];
  IDL_VPTR dy1_c = argv[2];
  IDL_VPTR dx2_c = argv[3];
  IDL_VPTR dy2_c = argv[4];
  int i;
  //float *result_data = (TYPE *) IDL_MakeTempArray(IDL_TYPE, 2, dims, IDL_ARR_INI_ZERO, &result);
  for (i = 0; i < 10; i++) {
    
  }
  return x;
}


int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the KCOR DLM. The information contained in these
   * tables must be identical to that contained in kcor.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_ucomp_quick_distortion, "UCOMP_QUICK_DISTORTION", 5, 5, 0, 0 },

  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in kcor.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
