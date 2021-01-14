set -e

mkdir -p release
./scripts/build.sh
cp output/main.pdf release/main.pdf