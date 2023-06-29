#!/bin/bash

cd `dirname $0`

if ! which dpkg-scanpackages 2>/dev/null >/dev/null ; then
    echo "dpkg-scanpackages missing" >&2
    exit 1
fi

if ! which apt-ftparchive 2>/dev/null >/dev/null ; then
    echo "apt-ftparchive missing; install package apt-utils" >&2
    exit 1
fi

cd ubuntu

for dist in dists/*/* ; do
    for d in packages binary-i386 binary-amd64 binary-arm64 ; do
        p=$dist/$d
        if [ -d $p -a ! -L $p ]; then
            echo $p
            dpkg-scanpackages -m $p > $p/Packages
            gzip -k -f $p/Packages
        fi
    done
    p=$dist/source
    if [ -d $p ]; then
        echo $p
        dpkg-scansources $p > $p/Sources
        gzip -k -f $p/Sources
    fi
done

for p in dists/xenial ; do
    echo $p
    apt-ftparchive release $p > $p/Release
    gpg --default-key github@rkraats.dds.nl -abs -o - $p/Release > $p/Release.gpg
    gpg --default-key github@rkraats.dds.nl --clearsign -o - $p/Release > $p/InRelease
done

