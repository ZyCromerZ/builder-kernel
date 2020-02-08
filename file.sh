#!/usr/bin/env bash
echo "done :p"
touch test.file
rsync -avP -e ssh "test.file" zycromerz@frs.sourceforge.net:/home/frs/project/zyc-test/