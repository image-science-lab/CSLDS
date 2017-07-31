Codebase for the paper

Sankaranarayanan, Turaga, Chellappa, and Baraniuk, “Compressive Acquisition of Linear Dynamical Systems,” in SIAM J. Imaging Sciences, 6(4), pp. 2109-2133, 2013

“@article{sankaranarayanan2013compressive,
title={Compressive acquisition of linear dynamical systems},
author={Sankaranarayanan, Aswin C. and Turaga, Pavan and Chellappa, Rama and Baraniuk, Richard},
journal={SIAM Journal on Imaging Sciences (SIIMS)},
volume={6},
number={4},
pages={2109--2133},
year={2013},
url_Paper={files/paper/2013/CSLDS_SIIMS.pdf},
pubtype = {Journal},
}

******* Run demo.m

It loads a dynamic texture of a candle and attempts to reconstruct it from noiselet measurements.

- Read paper at http://www.ece.rice.edu/~as48/research/cslds for additional details.
- You might need spgl1 package if you want to use the group-sparsity version of CSLDS.


Contents:

1) "cosamp" folder contains two codes for model-based CS.

- Cosamp_mean_cslds.m is the version for the mean+LDS model. This is the preferred implementation
- Cosamp_groupsparsity.m is the version with a group-sparsity term. The command spg_group in the toolbox SPGL1, in most cases, works better than this.
- Both codes can handle functional handles for the measurement operator.

2) run_cslds.m is the main workhorse script. demo.m gives an idea of how to use it.

3) "functions" folder
- Mainly a list of measurement and adjoint operators specific to the CSLDS framework. A lot different sparsifying basis are defined here.


4) "utility" folder
- Implementation of noiselets. Credits to Dr. Jason Laska (laska@rice.edu)


5) "dyntex"
has frames of a dynamic texture from the DynTex database. Unzip it.

