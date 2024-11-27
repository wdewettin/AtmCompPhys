import sys
from readfa.FA_to_CF import FA_to_CF
from datetime import datetime, timedelta
import os
import xarray as xr

### Define parameters ###

run_name = sys.argv[1]
cf_var_name_list = ["tas", "pr", "tasmax", "tasmin", "hfls", "hfss", "mrso", "ts", "rnetds", "tsl1", "tsl2", "mrsol1", "mrsol2", "mrsol3", "mrsfl1", "mrsfl2", "gflux", "evspsbl"]
teb_var_name_list = ["troad1"]
if run_name not in ["noTEB", "initSFXnoTEB"]:
    cf_var_name_list += teb_var_name_list
print(cf_var_name_list)

# ["clc", "clh", "cll", "clm", "clt", "evspsbl", "hurs", "huss", "pr", "ps", "rlds", "rsds", "rsdsdiff", "sfcWind", "tas", "tasmax", "tasmin", "uas", "vas"] # Variables to process
fullpos_cf_var_name_list = [] # ["ua700", "va700"] # ["psl"]
rstart = sys.argv[2]
nhours = int(sys.argv[3])

output_dir = f"/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_{run_name}_{rstart}_{nhours}/output" # The directory containing the FA-files
outputfilebase = "ICMSHABOF+" # The base of the FA-file names
fullpos_output_dir = f"/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_{run_name}_{rstart}_{nhours}/fullpos/output" # The directory containing the FA-files
fullpos_outputfilebase = "PFABOFABOF+" # The base of the FA-file names
store_dir = f"/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_{run_name}_{rstart}_{nhours}/store" # Directory to store the small netcdf-files with 2D output at single time steps
storefilebase = f"{run_name}_{rstart}_{nhours}" # The base of the name of the intermediate and final processed files
netcdf_dir = f"/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_{run_name}_{rstart}_{nhours}/netcdf" # Directory to store the combined raw model output in netcdf-format
cf_dir = f"/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_{run_name}_{rstart}_{nhours}/export" # Directory to store the final processed CF-compliant output
rbin = "/readonly/dodrio/apps/RHEL8/zen2-ib/software/R/4.2.1-foss-2022a/lib64/R/bin" # Optional: define the R bin directory to speed up the program
tree = True # Optional: organisational parameter to determine wheter to use a structure with subdirectories in the intermediate folders (i.e. a tree) or not
cf_data_path = "/dodrio/scratch/users/vsc45263/wout/readFA/data/ALARO_SURFEX_CF_variables.yml" # Path to the file containing the information about the CF-variables
global_attrs_path = "/dodrio/scratch/users/vsc45263/wout/readFA/data/example_CORDEX_attributes.yml"

# Define time-related parameters
tstep = 3600 # Time interval (in seconds) to determine the frequency of the processed output. If you, for example, want daily processed output, tstep needs to be equal to 24 * 3600
fstep = 3600 # Time difference (in seconds) between subsequent FA output files. If fstep = tstep then every FA-file will be processed.
mode = 0     # Parameter to determine how to handle "double" files. In long climate simulations midnight of the first day of every month has two files corresponding to that moment:
             # the last file of the previous month and the first file of the next month. Only one of these files is processed and this parameter determines which. If mode = 0 then 
             # the last file of the previous month is used; if mode = 2, then the first file of the next month is used.
zero_freq = "monthly"

rstart_datetime = datetime.strptime(rstart, "%Y%m%d%H")
toffset = (rstart_datetime - datetime(rstart_datetime.year, rstart_datetime.month, 1, 0)) // timedelta(seconds=1)
 
tstart_datetime = rstart_datetime + timedelta(hours=1)
tstart = datetime.strftime(tstart_datetime, "%Y-%m-%dT%H")
tstop_datetime = rstart_datetime + timedelta(hours=nhours)
tstop = datetime.strftime(tstop_datetime, "%Y-%m-%dT%H")

### Convert from FA to CF-compliant netcdf format ###

# Loop over the months January to May to process the data in each month.
FA_to_CF(cf_var_name_list, tstart, tstop, output_dir, outputfilebase, store_dir, storefilebase, netcdf_dir, cf_dir, cf_data_path, mode=mode, tstep=tstep, fstep=fstep, toffset=toffset, tree=tree, rbin=rbin, zero_freq=zero_freq, global_attrs_path=global_attrs_path)

# Add run_name and rstart to coordinates
for var_name in cf_var_name_list:
    file_name = os.path.join(cf_dir, var_name, f"{storefilebase}_{var_name}_{tstart}_{tstop}_{tstep}.nc")
    ds = xr.open_dataset(file_name, engine="netcdf4", chunks="auto")
    ds_assigned = ds.load().assign_coords({"rstart" : rstart, "run_name": run_name})
    ds.close()
    ds_assigned.to_netcdf(file_name, engine="netcdf4")
