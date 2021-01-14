set -e

watchexec --exts tex --ignore output/ -- './scripts/build.sh && echo "\n==reloaded==\n"'
