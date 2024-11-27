import os
import fnmatch
import xarray as xr

# Define the base directory to search from
base_dir = "/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs"

# Loop through the directory tree
for root, dirs, files in os.walk(base_dir):
    # Check if the current path matches the '*/export/*' pattern
    if fnmatch.fnmatch(root, "*/export/*"):
        print(f"Directory: {root}")
        root_split_list = root.split("/")
        run_info_list = root_split_list[-3].split("_")

        run_name = run_info_list[1]
        rstart = run_info_list[2]
        nhours = int(run_info_list[3])
        print(run_name, rstart, nhours)

        # Find all files ending with 'regridded.nc' in the current directory
        for file in files:
            if file.endswith("regridded.nc"):
                file_path_regridded = os.path.join(root, file)
                file_path = file_path_regridded[:-13] + ".nc"

                ds_regridded = xr.open_dataset(
                    file_path_regridded,
                    engine="netcdf4",
                    chunks="auto",
                    decode_times=False,
                )
                ds_regridded_loaded = ds_regridded.load()
                ds_regridded.close()

                ds = xr.open_dataset(
                    file_path, engine="netcdf4", chunks="auto", decode_times=False
                )
                time_bnds = ds.time_bnds.load()
                ds.close()

                if "time_bnds" in ds_regridded_loaded:
                    ds_regridded_loaded = ds_regridded_loaded.drop_vars("time_bnds")

                ds_regridded_loaded.coords["time_bnds"] = time_bnds
                ds_regridded_loaded.to_netcdf(file_path_regridded, engine="netcdf4")
                del ds_regridded_loaded
