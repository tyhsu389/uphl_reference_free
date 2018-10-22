# UPHL_Reference_Free

Houses scripts Tiffany Hsu wrote to run the UPHL Reference Free pipeline, as well as the documentation for running it.

## Step 1: Login to your username. Pull or copy the repository into any location.

Pulling the repository is preferred, but the internet speeds are slow, so this make take up to 30 minutes.  
Copying the repository should be almost instantaneous.

```
# To pull the repository, use git.
$ git pull _repository_

# To copy the repository, use "cp" (copy)
$ cp -r /home/thsu/gitlab/uphl_reference_free
# Change the permissions to your username so you can use the script
$ chown <YOURUSER>:state -R uphl_reference_free 
```

## Step 2: Create the directories for the pipeline.

Tiffany connected the tools within the UPHL Reference Free pipeline using the tool SnakeMake. SnakeMake requires you to create \
directories (or folders) to store the output before being run. Create directories within the `uphl_reference_free` folder.

```
# Run the included script to generate the directories.
$ sh scripts/initiate_dirs.sh 
```

## Step 3: Add your samples to the folder and put them in a list.

Samples should be inside `uphl_reference_free/BaseCalls` (inside a folder named `BaseCalls`). We only need the `fastq.gz` files. \
After, add the names of the `R1_001.fastq.gz` files to a file named `samples.txt`.

```
# Move your files (in a folder named "BaseCalls" to the uphl_reference_free folder.
$ cp -r /path/to/BaseCalls /path/to/uphl_reference_free

# Create a file with your sample names
$ ls -lh BaseCalls/* | cut -f10 -d' ' - > samples.txt

# Open up the text file to take a look
$ vi samples.txt
# Type ":i" to enter "insert mode", where you can type and make edits.
# Type ":q" to exit.
# Type ":w" to write/save your changes.
```

## Step 4: Run the main pipeline.

At this point, you should be ready to run the main pipeline. To do this, invoke Snakemake.

```
# Make sure you are in the folder "uphl_reference_free" 
$ snakemake -j
# j allows your computer to use all the resources it has access to.
```
