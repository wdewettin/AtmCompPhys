# AtmCompPhys
Exercises for the module Atmospheric Physics in the course of Computational Physics

This repository contains the notebooks used for the Atmospheric Physics module of Computational Physics, as well as for exercise sessions in Atmospheric Modelling. The `notebooks` directory contains the notebooks themselves, as well as accompanying scripts. The `simulations` directory contains the scripts used to run the simulations on Tier-1.

To update the notebook, the following steps need to be followed:
- Start a tunneling job on Tier-2 on the donphan cluster.
- Interrupt the command with CTRL+C.
- Activate the virtual environment from Scientific Computing (from Toon Verstraelen) with the `v` shortcut. Installation instructions can be found here: [link](https://github.ugent.be/Py4Sci/getting-started/blob/main/docs/setup_vsc.md)
- Add the Visual Studio Code module with `module load code-cli/1.104.1`.
- Restart the tunnel by running the interrupted command again: `code tunnel --accept-server-license-terms --name ${TUNNEL_NAME:0:20}`
- Only work in the solved versions of the notebooks. Tag each cell with a solution with the 'hide' tag.
- Create versions without solutions by running the `stripnb.py` script: [link](https://github.ugent.be/ComputationalPhysics/source/blob/main/modules/stripnb.py)
- When finished, copy the versions to the relevant repo, either for Computational Physics or for Atmospheric Modelling.
