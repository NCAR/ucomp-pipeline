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
    abundances_filename = info["abundances_filename"]
    rootgrp.abundances_filename = abundances_filename if abundances_filename is not None else "default"
    n_levels = info["n_levels"]
    rootgrp.n_levels = float(n_levels) if n_levels is not None else "all"
    # rootgrp.limbdark = "yes" if info["limbdark"] else "no"
    # rootgrp.protons = "yes" if info["protons"] else "no"
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


def compute_ratios(limbdark=True, protons=True, n_levels=None,
                   n_heights: int=99, min_height=1.01, max_height=2.0,
                   n_densities: int=120, min_density=6.0, max_density=12.0):
    chianti_dir, chianti_version = pycelp.chianti.getChiantiDir()
    # abundances_filename = os.path.join(chianti_dir,
    #     "abundance", "sun_coronal_2021_chianti.abund")
    abundances_filename = None

    fe13 = pycelp.Ion("fe_13", nlevels=n_levels, abundFile=abundances_filename)
    electron_temperature = fe13.get_maxtemp()
    # vs. Solarsoft max_temp('fe xiii')
    # electron_temperature = 1778279.410038923

    densities   = 10.0**np.linspace(min_density, max_density, n_densities)
    heights     = np.linspace(min_height, max_height, n_heights)

    n_lines     = 2
    intensities = np.zeros((n_lines, n_heights, n_densities))

    thetaBlocal = 0.0

# black body
# radtemp=5778.

    for height_index, height in enumerate(heights):
      print(f"{height_index+ 1} / {n_heights}: {height:0.2f} R_sun")
      for density_index, density in enumerate(densities):
        fe13.calc_rho_sym(density,
                          electron_temperature,
                          height - 1.0,
                          thetaBlocal,
                          include_limbdark=limbdark,  # maybe try with off?
                          include_protons=protons)
        line0 = fe13.get_emissionLine(10747.0)
        line1 = fe13.get_emissionLine(10789.0)
        intensities[0, height_index, density_index] = line0.calc_Iemiss()[0]
        intensities[1, height_index, density_index] = line1.calc_Iemiss()[0]

    ratios = intensities[0, :, :] / intensities[1, :, :]

    info = {"chianti_version": chianti_version,
        "electron_temperature": electron_temperature,
        "abundances_filename" : abundances_filename,
        "n_levels": n_levels,
        "limbdark": limbdark,
        "protons": protons}

    return(heights, densities, ratios, info)


if __name__ == "__main__":
    description = "UCoMP density ratio calculator"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--flag", "-f", default=None, type=str,
        help="flag to add to output filename")
    parser.add_argument("--output", "-o", default=None, type=str,
        help="output filename")
    parser.add_argument("--no-limbdark", default=False, action="store_true",
        help="set to not include limb darkening")
    parser.add_argument("--no-protons", default=False, action="store_true",
        help="set to not include protons")
    parser.add_argument("--nlevels", default=None, type=int,
        help="number of levels (default: all)")
    parser.add_argument("--nheights", default=99, type=int,
        help="number of heights (default: 99)")
    parser.add_argument("--min-height", default=1.01, type=float,
        help="min height (default: 1.01)")
    parser.add_argument("--max-height", default=2.0, type=float,
        help="max height (default: 2.0)")
    parser.add_argument("--ndensities", default=120, type=int,
        help="number of densities (default: 120)")
    parser.add_argument("--min-density", default=6.0, type=float,
        help="log of min density (default: 6.0)")
    parser.add_argument("--max-density", default=12.0, type=float,
        help="log of max density (default: 12.0)")
    args = parser.parse_args()

    limbdark    = not args.no_limbdark
    protons     = not args.no_protons
    n_levels    = args.nlevels
    n_heights   = args.nheights
    min_height  = args.min_height
    max_height  = args.max_height
    n_densities = args.ndensities
    min_density = args.min_density
    max_density = args.max_density

    try:
        import pycelp
        chianti_dir, chianti_version = pycelp.chianti.getChiantiDir()
    except NameError as e:
        parser.error("error finding Chianti database")

    # save the ratios, densities, and heights along with Chianti version
    if args.output is not None:
        basename = args.output
    else:
        flag = f"{args.flag}_" if args.flag is not None else ""
        basename = f"chianti_v{chianti_version}_pycelp_fe13_h{n_heights}_d{n_densities}_{flag}ratio.nc"

    print(f"limb darkening : {'YES' if limbdark else 'NO'}")
    print(f"protons        : {'YES' if protons else 'NO'}")
    print(f"# of levels    : {n_levels}")
    print(f"# of heights   : {n_heights}")
    print(f"height range   : {min_height:0.3f} - {max_height:0.3f} R_sun")
    print(f"# of densities : {n_densities}")
    print(f"density range  : 10**{min_density:0.2f} - 10**{max_density:0.2f}")

    t0 = datetime.datetime.now()

    heights, densities, ratios, info = compute_ratios(limbdark=limbdark,
        protons=protons, n_levels=n_levels, n_heights=n_heights,
        min_height=min_height, max_height=max_height, n_densities=n_densities,
        min_density=min_density, max_density=max_density)

    t1 = datetime.datetime.now()
    total_time = t1 - t0
    print(f"computation time: {total_time.total_seconds():0.1f} secs")
    write_ncdf(basename, heights, densities, ratios, info)
    print(f"wrote {basename}")
