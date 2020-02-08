#!/usr/bin/env bash
echo "done :p"
echo "test" > test.md
rsync -avP -e ssh -o StrictHostKeyChecking=no  "./test.md" $my_host@$upload_to:$link_project