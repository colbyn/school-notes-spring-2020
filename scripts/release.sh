set -e

rm -rf docs
rm -rf output-release
rm -rf output

subscript compile \
    --manifest subscript.toml \
    --output-dir output-release \
    --base-url https://colbyn.github.io/school-notes-spring-2020/

mv output-release docs

git add docs
git commit -m "update site"
git push

