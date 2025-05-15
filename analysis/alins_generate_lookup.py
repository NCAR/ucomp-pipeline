import pycelp 
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['figure.dpi'] = 150
from scipy.ndimage import gaussian_filter1d
import os
import pickle
import time
from tqdm import tqdm
os.environ["XUVTOP"] = '/hao/contrib/ssw/packages/chianti/dbase/' ## If you havent already set the environment variable XUVTOP for the location of the database, set it here

#la   = 150          ### Number of levels to include when doing the statistical equiblibrium and radiative transfer equations. The database has ~750 levels. Anything above 400 levels shoudl be enough.
fe13 = pycelp.Ion('fe_13')#,nlevels = la)

## Constants with respect to this specific caltulation
#electron_temperature = fe13.get_maxtemp()  ## kelvins; maximum formation temperature for Fe XIII. We will ado all calculations under this assumption. This implies we are approximating density only corresponding to plasma around this temperature.
electron_temperature = 1778279.4   # [K] Chianti max temperature
thetaBlocal          = 0.                  ## degrees; magnetic orientation. Value set to radial. Density sensitivity to this parameters is very low. This sensitivity will manifest at values orders of magnitude lower than the resolution space of the look-up table.
### arrays to store results
## The grid space defined here allows sampling 10 density values oper order of density magnitude with line ratios sensible to significant measurements of two decimals.

densities   = np.round(10.**np.linspace(6.,12,120),3)    ## array of densities to be probed. This gives roughly 10 density samples for each order of magnitude in the logarithmic density space spanning 10^6-10^12 electrons. 
height      = np.round(np.linspace(0.01,1.00,99) ,2)     ## solar radius units above the photosphere (add +1 to measure from disk center). This corresponds to offlimb heights of 1-2 solar radius, with intervals of 0.01
intensities = np.zeros((2,len(height),len(densities)))   ## to store both Fe XIII lines.
#alignments  = np.zeros((2],len(height),len(densities)))  ## we don't really need these for this calculations, but interesting avenues open if exploring

for h,eheight in enumerate(tqdm(height)):
    for d,edens in enumerate(densities):
        fe13.calc_rho_sym(edens,electron_temperature,eheight, thetaBlocal, include_limbdark=True, include_protons=True)
        ln1 = fe13.get_emissionLine(10747.)
        ln2 = fe13.get_emissionLine(10789.)
        intensities[0,h,d] = ln1.calc_Iemiss()[0]
        intensities[1,h,d] = ln2.calc_Iemiss()[0]
        #alignments[0,h,d]  = ln1.upper_level_alignment
        #alignments[1,h,d]  = ln2.upper_level_alignment
        
## compute the line ratios to be used as a height dependent look-up table with respect to the density grid spacing.
##
ratios = intensities[0,:,:] / intensities[1,:,:]
heights = height + 1.0

np.savez_compressed('./chianti_v'+pycelp.chianti.getChiantiDir()[1]+'_pycelp_fe13_h99_d120_ratio_3.npz',h=height,den=densities,rat=ratios)
