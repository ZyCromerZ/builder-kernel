#!/usr/bin/env bash
echo "done :p"
touch test.file
ssh -o StrictHostKeyChecking=no zycromerz@frs.sourceforge.net
rsync -avP -e ssh "test.file" zycromerz@frs.sourceforge.net:/home/frs/project/zyc-test/