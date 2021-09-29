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


// for x = 0L, dims[0] - 1L do begin
//   for y = 0L, dims[1] - 1L do begin
//     for c = 0L, dims[3] - 1L do begin
//       for e = 0L, n_exts - 1L do begin
//         data[x, y, *, c, e] = dmatrix ## reform(data[x, y, *, c, e])
//       endfor
//     endfor
//   endfor
// endfor
static IDL_VPTR IDL_ucomp_quick_demodulation(int argc, IDL_VPTR *argv) {
  IDL_VPTR dmatrix_vptr = argv[0];
  IDL_VPTR data_vptr    = argv[1];
  int n_dims;
  int x, n_cols, y, n_rows, n_polstates, c, n_cameras, e, n_extensions;
  int p_col, p_row;
  IDL_VPTR result;
  float *result_data, *dmatrix, *data;

  result_data = (float *)IDL_VarMakeTempFromTemplate(data_vptr,
                                                     IDL_TYP_FLOAT,
                                                     NULL,
                                                     &result,
                                                     1);
  dmatrix = (float *)dmatrix_vptr->value.arr->data;
  data = (float *)data_vptr->value.arr->data;

  n_dims = data_vptr->value.arr->n_dim;
  n_cols = data_vptr->value.arr->dim[0];
  n_rows = data_vptr->value.arr->dim[1];
  n_polstates = data_vptr->value.arr->dim[2];
  n_cameras = data_vptr->value.arr->dim[3];
  n_extensions = n_dims < 5 ? 1 : data_vptr->value.arr->dim[4];

  for (e = 0; e < n_extensions; e++) {
    for (c = 0; c < n_cameras; c++) {
      for (y = 0; y < n_rows; y++) {
        for (x = 0; x < n_cols; x++) {
          for (p_row = 0; p_row < n_polstates; p_row++) {
            for (p_col = 0; p_col < n_polstates; p_col++) {
              result_data[x +  (y  + (p_row + (c + e * n_cameras) * n_polstates) * n_rows) * n_cols] += dmatrix[p_row * n_polstates + p_col] * data[x +  (y +  (p_col + (c + e * n_cameras) * n_polstates) * n_rows) * n_cols];
            }
          }
        }
      }
    }
  }

  return(result);
}


// data = ucomp_quick_distortion(data, dx0_c, dy0_c, dx1_c, dy1_c)
//
// x = dindgen(nx, ny) mod nx
// y = transpose(dindgen(ny, nx) mod ny)
//
// dist_corrected = interpolate(sub_image, $
//                              x + ucomp_eval_surf(dx_c, dindgen(nx), dindgen(ny)), $
//                              y + ucomp_eval_surf(dy_c, dindgen(nx), dindgen(ny)), $
//                              cubic=-0.5, missing=0.0)
static IDL_VPTR IDL_ucomp_quick_distortion(int argc, IDL_VPTR *argv) {
  IDL_VPTR data_vptr = argv[0];
  IDL_VPTR dx0_c_vptr = argv[1];   // 4x4 array of coefficients
  IDL_VPTR dy0_c_vptr = argv[2];   // 4x4 array of coefficients
  IDL_VPTR dx1_c_vptr = argv[3];   // 4x4 array of coefficients
  IDL_VPTR dy1_c_vptr = argv[4];   // 4x4 array of coefficients
  int n_dims;
  int x, n_cols, y, n_rows, p, n_polstates, c, n_cameras, e, n_extensions;
  IDL_VPTR result;
  float *result_data, *data, *dx0_c_data, *dy0_c_data, *dx1_c_data, *dy1_c_data;
  float *dx0_surface, *dy0_surface, *dx1_surface, *dy1_surface;

  // TODO: allocate surfaces
  // TODO: initialize surfaces

  result_data = (float *)IDL_VarMakeTempFromTemplate(data_vptr,
                                                     IDL_TYP_FLOAT,
                                                     NULL,
                                                     &result,
                                                     1);
  n_dims = data_vptr->value.arr->n_dim;
  n_cols = data_vptr->value.arr->dim[0];
  n_rows = data_vptr->value.arr->dim[1];
  n_polstates = data_vptr->value.arr->dim[2];
  n_cameras = data_vptr->value.arr->dim[3];
  n_extensions = n_dims < 5 ? 1 : data_vptr->value.arr->dim[4];

  for (e = 0; e < n_extensions; e++) {
    for (c = 0; c < n_cameras; c++) {
      for (p = 0; p < n_polstates; p++) {
        for (y = 0; y < n_rows; y++) {
          for (x = 0; x < n_cols; x++) {
            // TODO: interpolate
          }
        }
      }
    }
  }

  return(result);
}


int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the KCOR DLM. The information contained in these
   * tables must be identical to that contained in kcor.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_ucomp_quick_demodulation, "UCOMP_QUICK_DEMODULATION", 2, 2, 0, 0 },
    { IDL_ucomp_quick_distortion, "UCOMP_QUICK_DISTORTION", 5, 5, 0, 0 },
  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in kcor.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
