# usr/bin/env fish
# gpa: git pull all
function gpa
    for d in */.git
        set repo (dirname $d)
        echo "== $repo =="
        git -C $repo pull; or echo "failed: $repo"
    end
end
