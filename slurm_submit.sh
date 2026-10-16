#!/usr/bin/env bash
# Submit one SLURM job per directory scan using list_files.sh.
#
# Usage:
#   ./submit_list_files.sh
#
# list_files.sh, the output lists and logs/ all live in SCRIPT_DIR below.

set -euo pipefail

SCRIPT_DIR="/cluster/projects/pughlab/DataTrack/group_scans"
LIST_SCRIPT="${SCRIPT_DIR}/list_files.sh"
LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOG_DIR"

if [[ ! -x "$LIST_SCRIPT" ]]; then
    echo "Error: $LIST_SCRIPT not found or not executable (chmod +x list_files.sh)" >&2
    exit 1
fi

# directory | output file | short job name
jobs=(
    "/cluster/projects/myelomagroup|myl_files.txt|scan_myl"
    "/cluster/projects/ovgroup|ovgroup_scan.txt|scan_ovgroup"
    "/cluster/projects/cgptip|cgtip_files.txt|scan_cgptip"
    "/cluster/projects/pughlab|pughlab_files.txt|scan_pughlab"
)

for entry in "${jobs[@]}"; do
    IFS='|' read -r dir out name <<< "$entry"

    jobid=$(sbatch --parsable \
        -p all \
        -J "$name" \
        -c 1 \
        --mem=4G \
        -t 24:00:00 \
        -o "${LOG_DIR}/${name}_%j.out" \
        -e "${LOG_DIR}/${name}_%j.err" \
        --wrap "\"$LIST_SCRIPT\" \"$dir\" \"${SCRIPT_DIR}/${out}\"")

    echo "Submitted $name (job $jobid): $dir -> $out"
done

echo "Check status with: squeue -u \$USER"
