#!/usr/bin/env bash
echo "done :p"
# touch test.md
# echo "test doang" > test.md
# rsync -avP -e "ssh -o StrictHostKeyChecking=no" "$(pwd)/test.md" $my_host@frs.sourceforge.net:/home/frs/project/zyc-test/
wget https://github.com/ZyCromerZ/builder-kernel/raw/master/sender.sh
chmod +x sender.sh
. sender.sh