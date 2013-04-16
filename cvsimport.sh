#!/bin/bash

version=$1

if [ -z "$version" ]; then
    echo "Usage: $0 version-number"
    echo "   Import CVS release branch"
    exit 0
fi

if ! [[ "$version" =~ ^[0-9]+$ ]]; then
    exec >&2; echo "Error: version must be a number"
    exit 1
fi

tag="release-$version"

if [ -n "$(git tag -l $tag)" ]; then
    exec >&2; echo "Error: Version $version has already been imported"
    exit 1
fi

for ens in ensembl*; do
    cd $ens
    cvs update -r branch-ensembl-$version
    cd -
done
git add *
git commit -a -m "CVS Branch: branch-ensembl-$version"
git tag $tag
