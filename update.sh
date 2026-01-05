#!/bin/bash
set -euxo pipefail

# sudo apt install git-filter-repo

rm -rf patches chromium
git clone --no-checkout https://chromium.googlesource.com/chromium/src.git chromium

pushd chromium
    git filter-repo \
        --prune-empty always \
        --path components/sync/protocol \
        --path LICENSE \
        --force

    git filter-repo \
        --prune-empty always \
        --path-glob '*.proto' \
        --path LICENSE \
        --force

    mkdir patches
    pushd patches
        git format-patch --root
    popd
popd

mv chromium/patches .

already_applied=0
if [ -f .applied-pos ]; then
    already_applied=$(cat .applied-pos)
fi

get_num_from_svnid() {
    [ "$patch_num" != x ] && return 0

    svnid_line=$(grep ^git-svn-id: "$1")
    if [ "$svnid_line" != "" ]; then
        patch_num="$(echo "$svnid_line" \
                     | cut -d' ' -f2 \
                     | cut -d'@' -f2)"
        return 0
    fi

    return 1
}

get_num_from_cr_commit_pos() {
    [ "$patch_num" != x ] && return 0
    cr_commit_pos_line=$(grep ^Cr-Commit-Position: "$1")
    if [ "$cr_commit_pos_line" != "" ]; then
        patch_num=$(echo "$cr_commit_pos_line" \
                    | cut -d'#' -f2 \
                    | cut -d'}' -f1)
        return 0
    fi

    return 1
}

while read -r path; do
    file_name="$(basename "$path")"
    patch_num=x

    if get_num_from_cr_commit_pos "$path" \
        || get_num_from_svnid "$path"; then
        if [ "$patch_num" -gt "$already_applied" ]; then
            echo "applying $path"
            git am --committer-date-is-author-date "$path"
            already_applied="$patch_num"
        else
            echo "skipping $file_name as it was already applied" >&2
        fi
    else
        echo "fail: cannot get commit pos for $file_name" >&2
        exit 1
    fi
done < <(find patches/ -type f | sort -n)

echo "$already_applied" > .applied-pos
git add .applied-pos || :
git commit -m 'chore: update .applied-pos' || :
