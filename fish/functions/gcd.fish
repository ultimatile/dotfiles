# gcd: ghq のリポジトリを fzf で選んで cd する
function gcd
    set -l repo (ghq list | fzf --query "$argv" --select-1 --exit-0)
    or return

    cd (ghq root)/$repo
end
