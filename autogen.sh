#!/bin/sh

# Fetch submodules if needed
echo "+ Setting up submodules"
git submodule update --init --recursive

cd egg-list-box
sh autogen.sh --no-configure
cd ..

AUTOPOINT='intltoolize --automake --copy' autoreconf -fiv -Wall || exit
./configure --enable-maintainer-mode "$@"
