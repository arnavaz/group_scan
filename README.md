# group-file-scans

Scripts that inventory every regular file under a project directory on the SLURM cluster. Symlinks are skipped. For each file, the output records its size, owner, group and last-modified time.

## Scripts

| Script | What it does |
|---|---|
| `list_files.sh` | Recursively lists regular files under one directory, skipping symlinked files and directories. Writes a tab-separated table. |
| `submit_list_files.sh` | Submits one SLURM job per group directory, each running `list_files.sh`. |

## Output format

Tab-separated, with a header row:

```
path	size_bytes	owner	group	last_modified
```

- `size_bytes`: file size in bytes
- `owner` / `group`: names, or numeric IDs if the account no longer exists
- `last_modified`: last content modification time (`YYYY-MM-DD HH:MM:SS`). To get ctime (the last change to permissions or ownership) instead, replace the `%T` codes in `fmt` with `%C`.

Read it in R with `read.delim("pughlab_files.txt")`.

## Usage

Scan one directory:

```bash
./list_files.sh /path/to/dir              # print to screen
./list_files.sh /path/to/dir files.txt    # write to file
```

Submit all group scans to SLURM:

```bash
./submit_list_files.sh
squeue -u $USER
```

`submit_list_files.sh` expects both scripts to be in `/cluster/projects/pughlab/DataTrack/group_scans`, and it writes the output lists and `logs/` there too. To scan more directories, add lines to the `jobs` array in the form `directory|output_file|job_name`.

Default job resources: partition `all`, 1 CPU, 4G memory, 24-hour time limit. Raise `-t` for very large directory trees.

## Notes

- "Permission denied" errors are suppressed. Files you can't read are silently left out of the list.
- Filenames containing tabs or newlines will break the table layout.
