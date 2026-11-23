# cwq: ghq 配下の worktree 一覧。`cwq cd [query]` は fzf で選んで cd する
function cwq
    if test "$argv[1]" = cd
        set -l dir (command cwq select $argv[2..-1])
        or return
        cd $dir
    else
        command cwq $argv
    end
end
