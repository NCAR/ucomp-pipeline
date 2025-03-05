import argparse
import os

import numpy as np

from netCDF4 import Dataset


def convert(filename: str):
    """Convert a .npz file to an .nc file with the same name, but different
    extension.
    """
    ncdf_filename = filename[0:-4] + ".nc"
    file = np.load(filename)

    print(f"reading {filename}...")
    print(f"writing {ncdf_filename}...")

    rootgrp = Dataset(ncdf_filename, "w", format="NETCDF4")

    rootgrp.chianti_version = "10.1"
    rootgrp.electron_temperature = 1676832.9
    rootgrp.abundances_basename = ""

    rootgrp.n_levels = np.nan
    rootgrp.invert = np.uint8(0)
    rootgrp.limbdark = np.uint8(1)
    rootgrp.protons = np.uint8(1)

    # variables h, den, rat(h_dim, den_dim)
    h_dim = rootgrp.createDimension("h", file["h"].shape[0])
    den_dim = rootgrp.createDimension("den", file["den"].shape[0])

    h = rootgrp.createVariable(f"/h", "f4", ("h",))
    den = rootgrp.createVariable(f"/den", "f4", ("den",))
    rat = rootgrp.createVariable(f"/rat", "f4", ("h", "den",))

    h[:] = file["h"]
    den[:] = file["den"]
    rat[:, :] = file["rat"]

    rootgrp.close()


if __name__ == "__main__":
    description = "UCoMP density .npz file converter (to netCDF)"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("files", nargs="+", help=".npz files")
    args = parser.parse_args()
    for filename in args.files:
        convert(filename)
