# usr/bin/env fish
# gpa: git pull all (parallel, grouped output)
function gpa
    set -l tmpdir (mktemp -d)
    for d in */.git
        set -l repo (dirname $d)
        begin
            git -C $repo pull >$tmpdir/$repo.log 2>&1
            or echo "__GPA_FAILED__" >>$tmpdir/$repo.log
        end &
    end
    wait

    set -l up_to_date
    set -l updated
    set -l failed

    for d in */.git
        set -l repo (dirname $d)
        set -l log (cat $tmpdir/$repo.log)
        if string match -q '*__GPA_FAILED__*' -- "$log"
            set -a failed $repo
        else if string match -q '*Already up to date*' -- "$log"
            set -a up_to_date $repo
        else
            set -a updated $repo
        end
    end

    if set -q updated[1]
        echo "── updated ──"
        for repo in $updated
            echo "== $repo =="
            cat $tmpdir/$repo.log
        end
    end

    if set -q failed[1]
        echo "── failed ──"
        for repo in $failed
            echo "== $repo =="
            sed '/__GPA_FAILED__/d' $tmpdir/$repo.log
        end
    end

    if set -q up_to_date[1]
        echo "── up to date ──"
        echo (count $up_to_date)" repos: $up_to_date"
    end

    rm -rf $tmpdir
end
