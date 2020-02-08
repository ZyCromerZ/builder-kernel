#!/usr/bin/env bash
echo "done :p"
auth() {
    ssh -o StrictHostKeyChecking=no $my_host@$upload_to
}
send() {
    touch test.md
    rsync -avP -e ssh "./test.md" $my_host@$upload_to:$link_project
}
auth >/dev/null
send >/dev/null