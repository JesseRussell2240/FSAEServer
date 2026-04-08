#!/usr/bin/env bash
set -euo pipefail

if ! command -v svn >/dev/null 2>&1; then
    echo "svn command not found."
    exit 1
fi

WORKING_COPY="${1:-}"

if [[ -z "${WORKING_COPY}" || ! -d "${WORKING_COPY}" ]]; then
    echo "Usage: $0 /path/to/working-copy"
    exit 1
fi

count=0
while IFS= read -r -d '' file; do
    svn propset svn:needs-lock "*" "${file}" >/dev/null
    svn propset svn:mime-type "application/octet-stream" "${file}" >/dev/null
    count=$((count + 1))
done < <(
    find "${WORKING_COPY}" -type f \
        \( \
            -iname "*.sldprt" -o \
            -iname "*.sldasm" -o \
            -iname "*.slddrw" -o \
            -iname "*.step" -o \
            -iname "*.stp" -o \
            -iname "*.igs" -o \
            -iname "*.iges" -o \
            -iname "*.x_t" -o \
            -iname "*.x_b" -o \
            -iname "*.dxf" -o \
            -iname "*.dwg" -o \
            -iname "*.pdf" \
        \) \
        -print0
)

echo "Processed ${count} files."
echo "Review changes, then commit the property updates from the working copy."
