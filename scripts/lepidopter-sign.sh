#!/bin/sh
set -e

DIR="images"
LEPIDOPTER_SIGN_KEY="0xBA56AC5A53E9C7A4"

echo "Compute SHA message digests..."
cd $DIR
sha1sum *.xz > SHA1SUM
sha256sum *.xz > SHA256SUM
sha512sum *.xz > SHA512SUM

echo "Signing..."
for f in * ; do
    gpg2 --verbose --armor --default-key ${LEPIDOPTER_SIGN_KEY} --detach-sign $f
done
