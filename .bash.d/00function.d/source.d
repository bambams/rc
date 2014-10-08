function source.d
{
    if [ ! -z "$1" ]; then
        local name=".$1";
    fi;

    for f in `find -L "$HOME/.bash.d$name" -type f | sort`; do
        source "$f";
    done;
}
