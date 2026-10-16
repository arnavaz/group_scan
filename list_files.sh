#!/usr/bin/env bash
# List all regular files under a directory (recursively), skipping symlinks,
# with size, owner, group and last-modified time.
#
# Output is tab-separated with a header:
#   path  size_bytes  owner  group  last_modified
#
# Usage:
#   ./list_files.sh <directory> [output_file]
#
# Examples:
#   ./list_files.sh /data/project
#   ./list_files.sh /data/project file_list.tsv

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <directory> [output_file]" >&2
    exit 1
fi

dir="$1"
out="${2:-}"

if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a directory" >&2
    exit 1
fi

# Resolve to an absolute path so the output paths are absolute
dir="$(cd "$dir" && pwd -P)"

header=$'path\tsize_bytes\towner\tgroup\tlast_modified'

# -type f  : regular files only (symlinks are type 'l', so they're excluded)
# find does not follow symlinked directories by default (no -L), so those are skipped too
# -printf fields:
#   %p  full path
#   %s  size in bytes
#   %u  owner (numeric UID if the user no longer exists)
#   %g  group (numeric GID if the group no longer exists)
#   %T  last content modification time, as YYYY-MM-DD HH:MM:SS
# 2>/dev/null hides "Permission denied" noise; remove it if you want to see those
fmt='%p\t%s\t%u\t%g\t%TY-%Tm-%Td %TH:%TM:%.2TS\n'

if [[ -n "$out" ]]; then
    {
        echo "$header"
        find "$dir" -type f -printf "$fmt" 2>/dev/null
    } > "$out"
    echo "Wrote $(( $(wc -l < "$out") - 1 )) file entries to $out" >&2
else
    echo "$header"
    find "$dir" -type f -printf "$fmt" 2>/dev/null
fi
