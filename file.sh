#!/usr/bin/env bash
echo "done :p"
echo "test" > test.md
ssh -o StrictHostKeyChecking=no $my_host@$upload_to
rsync -avP -e ssh "./test.md" $my_host@$upload_to:$link_project