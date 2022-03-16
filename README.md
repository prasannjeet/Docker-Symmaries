# Symmaries Docker Image

A docker image to run Symmaries.

## Instructions

### Prerequisites
1. **Docker installed in your system.**
1. **Input for Symmaries:** all the input files needed to run symmaries is required, i.e. the `Meth` folder and `types.classes` file. Both this should be placed in one folder. Let’s assume we save the files in the folder name `input-folder`. The folder structure must be something like below:
```
    input-folder/
    ├─ types.classes
    ├─ generation-errors.log
    ├─ Meth/
    │  ├─ all.secstubs
    │  ├─ all.meth_files
    │  ├─ all.srcs
    │  ├─ com.example.intenttesting.MainActivity_onCreate1469897960.meth
    │  ├─ com.example.intenttesting.R$styleable_clinit1519815637.meth
    │  ├─ com.example.intenttesting.databinding.ActivityMainBinding.meth
```

### Steps
1. Create a new folder, let's call it `symmaries-docker`.
1. Create a file called `docker-compose.yml` inside the folder.
1. Copy the contents from `docker-compose-template.yml` from this repository and paste in `docker-compose.yml` just created.
1. Replace `/absolute/location/where/meth/folder/is/located` with the absolute location of `input-folder` that we created above. Everything else must be the same. This will mirror the input file inside the Symmaries container.
1. Now, open the terminal, `cd` to this directory (`symmaries-docker`), and run the following command:
    ```shell
    docker-compose up -d
    ```
    This will start the docker container.
1. Now, the input files are already mapped in the folder `/home/opam/output` inside the docker container. However, in the file `all.meth_files`, all the paths are relative to the host computer, and we need to change it so that the paths change relative to the docker container. For that, we first need to run a command *inside* the container. For that, first run the command:
    ```shell
    docker exec -it symmaries /bin/bash
    ```
    Now, we are inside the Symmaries container.
1. Next, run the following command, that will automatically change the paths inside the file `all.meth_files` relative to the symmaries docker container.
    ```shell
    sed -i -e 's/^.*Meth\//\/home\/opam\/output\/Meth\//g' "/home/opam/output/Meth/all.meth_files"
    ```
1. Now we are ready to run Symmaries command. The executable file `syrs.opt` is located at `/home/opam/.opam/4.07.0/bin/syrs.opt`. Thus, one sample command could be like so:
    ```shell
    /home/opam/.opam/4.07.0/bin/syrs.opt -of secsum --methskip-cond 150 --log-level i -tf -exceptions types.classes Meth/all.meth_files Meth/all.secstubs --full-walk --output results.secsums --output results.meth_stats
    ```
1. Once the commands are run, the container can be shut down. First execute the command `exit` to come out of the command line of the docker container. After that, run the command `docker-compose down` to stop the container.

    That's it!
    
    ---

Note: If the input file for Symmaries (such as `input-folder` in our case) is created automatically via a program, it is recommended to directly map that folder in `docker-compose.yml` so that no copy-paste will be required.

The container can be kept on for the whole session. Just re-build all the input files, execute the command to change paths (`Step 7`), then run the Symmaries command.