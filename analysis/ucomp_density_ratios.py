#!/usr/bin/env python

import argparse
import datetime
import os

import numpy as np
from netCDF4 import Dataset


def write_ncdf(filename: str, heights, densities, ratios, info):
    rootgrp = Dataset(filename, "w", format="NETCDF4")

    rootgrp.chianti_version = info["chianti_version"]
    rootgrp.electron_temperature = info["electron_temperature"]
    abundances_basename = info["abundances_basename"]
    rootgrp.abundances_basename = abundances_basename if abundances_basename is not None else ""
    n_levels = info["n_levels"]
    rootgrp.n_levels = float(n_levels) if n_levels is not None else np.nan
    rootgrp.invert = np.uint8(info["invert"])
    rootgrp.limbdark = np.uint8(info["limbdark"])
    rootgrp.protons = np.uint8(info["protons"])

    heights_dim = rootgrp.createDimension("n_heights", heights.shape[0])
    densities_dim = rootgrp.createDimension("n_densities", densities.shape[0])

    heights_variable = rootgrp.createVariable(f"/h", "f4", ("n_heights",))
    densities_variable = rootgrp.createVariable(f"/den", "f4", ("n_densities",))
    ratios_variable = rootgrp.createVariable(f"/rat", "f4", ("n_heights", "n_densities",))

    heights_variable[:] = heights
    densities_variable[:] = densities
    ratios_variable[:, :] = ratios

    rootgrp.close()


def compute_ratios(abundances_basename=None, chianti_maxtemp=False,
                   invert=False, limbdark=True, protons=True,
                   n_levels=None,
                   n_heights: int=240, min_height=1.005, max_height=2.2,
                   n_densities: int=120, min_density=6.0, max_density=12.0):
    chianti_dir, chianti_version = pycelp.chianti.getChiantiDir()

    if abundances_basename is not None:
        abundances_filename = os.path.join(chianti_dir,
            "abundance", f"{abundances_basename}.abund")
    else:
        abundances_filename = None

    fe13 = pycelp.Ion("fe_13", nlevels=n_levels, abundFile=abundances_filename)

    # get_maxtemp produces a temperature of 1676832 K, whereas Solarsoft Chianti
    # routine MAX_TEMP give a temperature of 1778279 K.
    if chianti_maxtemp:
        electron_temperature = 1778279.0
    else:
        electron_temperature = fe13.get_maxtemp()

    densities   = 10.0**np.linspace(min_density, max_density, n_densities)
    heights     = np.linspace(min_height, max_height, n_heights)

    n_lines     = 2
    intensities = np.zeros((n_lines, n_heights, n_densities))

    thetaB_local = 0.0

    for height_index, height in enumerate(heights):
      print(f"{height_index+ 1} / {n_heights}: {height:0.2f} R_sun")
      for density_index, density in enumerate(densities):
        fe13.calc_rho_sym(density,
                          electron_temperature,
                          height - 1.0,
                          thetaB_local,
                          include_limbdark=limbdark,
                          include_protons=protons)
        line0 = fe13.get_emissionLine(10747.0)
        line1 = fe13.get_emissionLine(10789.0)
        intensities[0, height_index, density_index] = line0.calc_Iemiss()[0]
        intensities[1, height_index, density_index] = line1.calc_Iemiss()[0]

    if invert:
        ratios = intensities[1, :, :] / intensities[0, :, :]
    else:
        ratios = intensities[0, :, :] / intensities[1, :, :]

    info = {
        "chianti_version": chianti_version,
        "electron_temperature": electron_temperature,
        "abundances_basename" : None if abundances_basename is None else f"{abundances_basename}.abund",
        "n_levels": n_levels,
        "invert": invert,
        "limbdark": limbdark,
        "protons": protons}

    return(heights, densities, ratios, info)


if __name__ == "__main__":
    description = "UCoMP density ratio calculator"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--name", "-n", default=None, type=str,
        help="name to add to output filename")
    parser.add_argument("--output", "-o", default=None, type=str,
        help="output filename")
    parser.add_argument("--abundances-basename", "-a", default=None, type=str,
        help="abundances basename, i.e., 'sun_coronal_2021_chianti'")
    parser.add_argument("--chianti-maxtemp", default=False, action="store_true",
        help="temperature is normally 1676832 K, if set use Chianti's temperature 1778279 K")
    parser.add_argument("--invert", "-i", default=False, action="store_true",
        help="normally ratio computed is 1074/1079, this option inverts it")
    parser.add_argument("--no-limbdark", default=False, action="store_true",
        help="set to not include limb darkening")
    parser.add_argument("--no-protons", default=False, action="store_true",
        help="set to not include protons")
    parser.add_argument("--n-levels", default=None, type=int,
        help="number of levels (default: all)")
    parser.add_argument("--n-heights", default=240, type=int,
        help="number of heights (default: 240)")
    parser.add_argument("--min-height", default=1.005, type=float,
        help="min height (default: 1.005)")
    parser.add_argument("--max-height", default=2.2, type=float,
        help="max height (default: 2.2)")
    parser.add_argument("--n-densities", default=120, type=int,
        help="number of densities (default: 120)")
    parser.add_argument("--min-density", default=6.0, type=float,
        help="log of min density (default: 6.0)")
    parser.add_argument("--max-density", default=12.0, type=float,
        help="log of max density (default: 12.0)")
    args = parser.parse_args()

    abundances_basename = args.abundances_basename
    chianti_maxtemp     = args.chianti_maxtemp
    invert              = args.invert
    limbdark            = not args.no_limbdark
    protons             = not args.no_protons
    n_levels            = args.n_levels
    n_heights           = args.n_heights
    min_height          = args.min_height
    max_height          = args.max_height
    n_densities         = args.n_densities
    min_density         = args.min_density
    max_density         = args.max_density

    try:
        import pycelp
        chianti_dir, chianti_version = pycelp.chianti.getChiantiDir()
    except NameError as e:
        parser.error("error finding Chianti database")

    # save the ratios, densities, and heights along with Chianti version
    if args.output is not None:
        basename = args.output
    else:
        name = f"{args.name}_" if args.name is not None else ""
        basename = f"chianti_v{chianti_version}_pycelp_fe13_h{n_heights}_d{n_densities}_{name}ratio.nc"

    print(f"abundances basename : {abundances_basename}")
    print(f"chianti_maxtemp     : {'YES' if chianti_maxtemp else 'NO'}")
    print(f"invert              : {'YES' if invert else 'NO'}")
    print(f"limb darkening      : {'YES' if limbdark else 'NO'}")
    print(f"protons             : {'YES' if protons else 'NO'}")
    print(f"# of levels         : {'all' if n_levels is None else n_levels}")
    print(f"# of heights        : {n_heights}")
    print(f"height range        : {min_height:0.3f} - {max_height:0.3f} R_sun")
    print(f"# of densities      : {n_densities}")
    print(f"density range       : 10**{min_density:0.2f} - 10**{max_density:0.2f}")

    t0 = datetime.datetime.now()

    heights, densities, ratios, info = compute_ratios(
        abundances_basename=abundances_basename,
        chianti_maxtemp=chianti_maxtemp,
        invert=invert, limbdark=limbdark, protons=protons, n_levels=n_levels,
        n_heights=n_heights, min_height=min_height, max_height=max_height,
        n_densities=n_densities,
        min_density=min_density, max_density=max_density)

    t1 = datetime.datetime.now()
    total_time = t1 - t0
    print(f"computation time: {total_time.total_seconds():0.1f} secs")
    write_ncdf(basename, heights, densities, ratios, info)
    print(f"wrote {basename}")
