# Setup on VSC Clusters

The [Flemish Supercomputer Center (VSC)](https://www.vscentrum.be/)
supports interactive sessions to run Jupyter notebooks directly on advanced compute nodes.
The following instructions are written for students and researchers
affiliated with one of the Flemish universities,
and assume that you are using the Tier-2 cluster at Ghent University,
which accessible to all VSC users.

If you are affiliated with a Flemish university, but don't have a VSC account yet,
you need to request one first.
For some courses, accounts are already created for students, so they no longer need to request one.
The exact procedure depends on your host institution.
Students and researchers at Ghent University can apply for a VSC account
[here](https://www.ugent.be/hpc/en/access/policy/access).

Once your VSC account has been created, you should be able to log in at
[login.hpc.ugent.be](https://login.hpc.ugent.be).


## Basic Virtual Terminal Skills

To follow this guide, you will need to become familiar with
[virtual terminals, which are explained elsewhere](terminal.md).


## Configure SSH Access From the Cluster to `github.ugent.be`

You will need this to "clone" the course material in your VSC account.

1. Navigate to [login.hpc.ugent.be](https://login.hpc.ugent.be) and follow the steps to log in.

1. In the blue top bar, click `Clusters` > `>_ RHEL8 Login node Shell Access`.
   A new tab will open with a black screen and a welcome message
   containing some information about the current state of the clusters.

1. Once you have a virtual terminal, follow the instructions
   in [ssh_github_ugent.md](ssh_github_ugent.md).


## Software Installation

The VSC clusters come with a large amount of computational software readily installed,
which can be a bit overwhelming.
Another challenge is creating a proper Python virtual environment on the VSC clusters,
which is more complicated than creating them on your own computer.
This section will help you overcome these challenges
by providing a simple software environment that is geared towards novice users.

We provide a script `job_install_vsc.sh` below to install the software environment.
This script must be *submitted* to the clusters you intend to use.
(Do not run it on the login node.)
You can submit this job script as follows.

1. Navigate to [login.hpc.ugent.be](https://login.hpc.ugent.be) and follow the steps to log in.

1. In the blue top bar, click `Clusters` > `>_ RHEL8 Login node Shell Access`.

1. Clone this `getting-started` repository:

    ```bash
    mkdir ${VSC_DATA}/scicomp
    cd ${VSC_DATA}/scicomp
    git clone git@github.ugent.be:Py4Sci/getting-started.git
    ```
    > ```
    > Cloning into 'getting-started'...
    > remote: Enumerating objects: 16, done.
    > remote: Counting objects: 100% (16/16), done.
    > remote: Compressing objects: 100% (14/14), done.
    > remote: Total 16 (delta 1), reused 16 (delta 1), pack-reused 0
    > Receiving objects: 100% (16/16), 87.06 KiB | 2.56 MiB/s, done.
    > Resolving deltas: 100% (1/1), done.
    > ```

1. Enter the cloned repository and submit the installation script to the Donphan cluster,
   with the following commands:

    ```bash
    cd getting-started/setup
    module swap cluster/donphan
    sbatch job_install_vsc.sh
    ```
    > ```
    > Submitted batch job 20082816 on cluster donphan
    > ```

    The same installation script also works for other clusters,
    but you do not need them to get started.
    (This would also occupy space in your `$VSC_DATA`, where students have limited quota.)

    Note that it can take a while for the installation jobs to start and end.
    You can check the job status on all clusters with the command `squeue --cluster=ALL`.
    When there are no listed in the output of `squeue`, the installation has completed.

    Wait for the installation to complete before proceeding to the next sections.

1. Type `exit` to close the terminal.


## Configure Your "Shell"

When you work in a virtual terminal you are actually using a program that takes
your commands, and then interprets and executes them.
This program is called a "shell" and the one you have been using specifically is called "bash".

The default configuration of bash on the VSC clusters is quite basic,
essentially because everyone has their own preferences on how to configure bash.

To configure bash, you need to extend your `~/.bashrc` file.
You can edit this file with the command `nano ~/.bashrc` in the terminal,
or use the HPC web portal, depending on how adventurous you are.

In the HPC web portal, select `Files` -> `Home directory` in the blue bar.
The check the box in front of `Show Dotfiles`, and scroll down until you find `.bashrc`.
Click on the three dots to the right of this file (`⋮🢓`) and select `🖉 edit`.
Add the following to at the end of the file and click `Save` when you are done:

```bash
# Make bash more fun to use
source ${VSC_DATA}/scicomp/venvs/3.11.5-GCCcore-13.2.0/powerbash.sh

# Make Git more fun to use by enabling tab completion for Git
source /usr/share/bash-completion/completions/git

# Sensible defaults
export HISTFILESIZE=10000
export EDITOR=nano

# A few generally useful aliases, which are like command-line shortcuts.
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'

# Aliases for interactive jobs. Don't use these for production computations.
for num in $(seq 1 36); do
    alias work${num}="srun --pty -t 6:00:00 --ntasks=1 --cpus-per-task=${num} bash"
done

# Covenient cluster-related aliases.
alias qa='squeue --cluster=ALL'
# Pokemons are cool, but why do some start with the same letter?
# Only the HPC admins know...
alias a='module swap cluster/accelgor'
alias d='module swap cluster/doduo'
alias n='module swap cluster/donphan'
alias g='module swap cluster/gallade'
alias j='module swap cluster/joltik'
alias s='module swap cluster/shinx'
alias t='module swap cluster/skitty'
alias w='watch -n2 squeue -l'
alias sc="cd ${VSC_SCRATCH}"
alias da="cd ${VSC_DATA}"
alias v="source $VSC_DATA/scicomp/venvs/3.11.5-GCCcore-13.2.0/activate.sh"
```

Note that these settings will only take effect after you save the file
and open a new terminal.

It is not recommended activating software modules in this file,
as it is slow and it may have unexpected side effects.
Instead, we defined the `v` alias,
which you can use in the terminal whenever you want to use the software environment.
(This will be shown below.)


## Test Jupyter Lab

1. Go back to [login.hpc.ugent.be](https://login.hpc.ugent.be)
   and click on `Interactive Apps` > `Jupyter Lab`, which will open a new page.

1. Select a cluster and the resources that you want to use.
   The more resources you request (hours, number of nodes and number of cores),
   the longer you will have to wait to get access to you session.

    - **Cluster:** `donphan (interactive/debug)`
      (There is practically no queuing time on this cluster.)
    - **Time (hours):** Enter the amount of time you will be working on the notebook.
      Your session will be killed when this time is up.
    - **Number of nodes:** always `1`
    - **Number of cores per node:** `2`
    - **JupyterLab version:** `None (advanced)`
    - **Custom code:**
        ```bash
        source ${VSC_DATA}/scicomp/venvs/3.11.5-GCCcore-13.2.0/activate.sh
        ```
    - **Extra Jupyter Arguments:**
        ```bash
        --notebook-dir="${VSC_DATA}/scicomp"
        ```
    - **Reservation ID:** none
    - **Extra sbatch arguments:** leave empty
    - **I would like to receive an email when the session starts:** no need to check this.

    Most of these settings are already correct by default.

1. Scroll down and click the `Launch` button.

    Your job will be queued and will not start until the requested resources become available.
    (For more information, see <https://docs.hpc.ugent.be/Linux/running_batch_jobs/>.)
    Normally, the above settings should ensure a near-instantaneous start of your session
    with workable resources to run a simple Jupyter notebook.

    A new screen will appear showing the status of your request (queuing or about to start).
    Typically, you should see the following:

    ```
    Your session is currently starting... Please be patient as this process can take a few minutes.
    ```

1. After a minute, you will see a button that says `Connect to Jupyter Lab`.
   Click this button and a Jupyter Lab should open in a new tab.

1. In the `Launcher` tab, under `Notebook`, click `Python 3 (ipykernel)`.
   A new notebook will open.

1. Enter the following lines in the first code cell and execute it
   by clicking the `▶️` button in the toolbar (or by pressing Shift+Enter):

    ```python
    import numpy as np
    np.fft.test()
    ```
    > ```
    > /apps/gent/RHEL8/cascadelake-ib/software/SciPy-bundle/2023.11-gfbf-2023b/lib/python3.11/site-packages/numpy/_pytesttester.py:144: DeprecationWarning:
    >
    >   `numpy.distutils` is deprecated since NumPy 1.23.0, as a result
    >   of the deprecation of `distutils` itself. It will be removed for
    >   Python >= 3.12. For older Python versions it will remain present.
    >   It is recommended to use `setuptools < 60.0` for those Python versions.
    >   For more details, see:
    > https://numpy.org/devdocs/reference/distutils_status_migration.html
    >
    >   from numpy.distutils import cpuinfo
    > NumPy version 1.26.2
    > NumPy relaxed strides checking option: True
    > NumPy CPU features:  SSE SSE2 SSE3 SSSE3 SSE41 POPCNT SSE42 AVX F16C FMA3 AVX2 AVX512F AVX512CD AVX512_SKX AVX512_CLX AVX512_KNL? AVX512_KNM? AVX512_CNL? AVX512_ICL? AVX512_SPR?
    > ........................................................................................                                         [100%]
    > 88 passed in 1.45s
    > ```

   The warnings are harmless, no need to worry.

1. Open the notebooks `factorial.ipynb` and `estimate_pi.ipynb`
   in the `getting-started/demo` directory and follow the instructions to run them.

1. Open the file `getting-started/demo/notes.tex` and follow the instructions in this file.

1. Exit Jupyter Lab, by selecting `File` -> `Shut Down` in the menu.


## Test Python and Git in an Interactive Job

1. Go back to [login.hpc.ugent.be](https://login.hpc.ugent.be)
   and click `Interactive Apps` -> `Shell (tmux)` in the blue bar.

   This is shell is a bit more robust than the one started through
    `Cluster` -> `>_ RHEL8 Login node Shell Access`,
   and we need this robustness for the following steps to work.
   Anytime you need to work in a terminal on the cluster, we recommend this one.

1. Select the Donphan cluster from the list of clusters.
   Other settings can be left to their defaults.
   Finally, scroll down and click the blue `Launch` button.

1. A job is started on Donphan for your tmux shell,
   which is comparable to how you started Jupyter Lab.
   After a minute, you should be able to click the `Connect` button to open the shell.

1. Activate the software environment in the tmux shell with the following command:

    ```bash
    v
    ```

    This will take a few seconds, after which you see the following in the terminal:

    > ```
    > The following modules were not unloaded:
    >   (Use "module --force purge" to unload all):
    >
    >   1) env/vsc/donphan   2) env/slurm/donphan   3) env/software/donphan   4) cluster/donphan
    > ```

    Now you have access to all the software installed with the `job_install_vsc.sh` script.

1. Test the FFT package NumPy installation.

    ```bash
    python -c "import numpy as np; np.fft.test()"
    ```

    You should have Python 3.11 and the NumPy FFT tests should pass,
    showing the same warnings as above.

1. You can test Git by simply printing the help message:

    ```bash
    git --help
    ```
    > ```
    > usage: git [-v | --version] [-h | --help] [-C <path>] [-c <name>=<value>]
    >        [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
    >        [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
    >        [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
    >        [--super-prefix=<path>] [--config-env=<name>=<envvar>]
    >        <command> [<args>]
    >
    > ...
    > ```

1. Test `pre-commit` in the `getting-started` repository:

    ```bash
    cd ${VSC_DATA}/scicomp/getting-started
    pre-commit install
    ```
    > ```
    > pre-commit installed at .git/hooks/pre-commit
    > ```

    ```
    pre-commit run --all
    ```
    > ```
    > [INFO] Installing environment for ...
    > ...
    > trim trailing whitespace.................................................Passed
    > ruff-format..............................................................Passed
    > ruff.....................................................................Passed
    > nb-clean.................................................................Passed
    > ```

    [Pre-commit](https://pre-commit.com/) is a popular tool for cleaning up your changes to the
    files in the Git repositories before committing and pushing those changes to GitHub.


## How to update the Python packages in your `$VSC_DATA`

Throughout the semester, there have been a few updates to the list of Python packages,
which are installed by the script `job_install_vsc.sh`.
You may need to update your local installation with those changes to fix a bug
or to install packages added after the start of the semester, which are needed for a course.

To perform the update, open under `Interactive Apps` a new `Shell (tmux)` on Donphan,
as you did in the previous section. (See steps above).
Then change to the directory with the setup scripts as follows:

```bash
cd ${VSC_DATA}/scicomp/getting-started/setup
```

Update your clone of the `getting-started` repository with the latest online changes:

```bash
git pull
```

Run the setup script locally:

```bash
./job_install_vsc.sh
```

There is no need to submit this job on the queue,
because your tmux session is already running on a Donphan compute node.

The installation script will produce a lot of output and
will have completed once you see the command prompt.
Now you are done!
You can close the tmux session.
In your future Jupyter Lab sessions, the newly installed or updated software will be available.


## Further Reading

- The [UGent HPC team](https://www.ugent.be/hpc/en) has excellent documentation:
  <https://docs.hpc.ugent.be/>.
  The documentation includes an introduction to the Linux commands
  you have been entering in the virtual terminal.

- The clusters in Ghent are part of the
  [Vlaams Supercomputer Centrum (VSC)](https://www.vscentrum.be/),
  where you can find additional documentation: <https://docs.vscentrum.be/>

- SSH client software can be more user-friendly and faster than the web interface.
  Documentation for setting up an SSH client for the VSC clusters can be found for different operating systems in two locations:

    - The [VSC documentation for accessing the clusters](https://docs.vscentrum.be/access/access_methods.html).
      **For Windows users, we recommend [MobaXTerm](https://mobaxterm.mobatek.net/) described in [this documentation](https://docs.vscentrum.be/access/access_using_mobaxterm.html), not PuTTy.**
    - The [UGent HPC documentation](https://docs.hpc.ugent.be) contains similar instructions,
      but only discusses PuTTy for Windows users, not MobaXTerm.

    Irrespective of your operating system, you need to make a **new** SSH key pair to access the VSC clusters.
    We do not recommended reusing the SSH key pair you use to access <https://github.ugent.be> from the clusters.

    For **macOS and Linux** users, you can facilitate the usage of your SSH client by putting a configuration section along the following lines in a file `~/.ssh/config`:

    ```
    Host gligar
        Hostname login.hpc.UGent.be
        user vsc4XXXX
        IdentityFile %d/.ssh/id_rsa_vsc
    ```

    where you replace `vsc4XXXX` by your VSC id.
    This configuration assumes the keys were generated with the following command:

    ```bash
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_vsc
    ```

    With this configuration, you can connect to the cluster by simply typing `ssh gligar` in your terminal.
