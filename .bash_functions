function mkscreen
{
    local add=n

    if [ "$1" == '-a' ]; then
        add=y
        shift;
    fi

    local name=$1;
    shift;
    local command="$*";

    if [ -z "$name" -o -z "$command" ]; then
        echo 'Usage: mkscreen [ -a ] name command

    -a          Add to .bashrc.' 1>&2;
        return 1;
    fi

    if [ $add == y ]; then
        echo "mkscreen $name $command" >> $HOME/.bash_screens;
    fi

    alias $name="/usr/bin/screen -d -RR -S $name $command";

    return 0;
}

function rmscreen
{
    local delete=n

    if [ "$1" == '-d' ]; then
        delete=y
        shift;
    fi

    local name=$1;

    if [ -z "$name" ]; then
        echo 'Usage: rmscreen [ -d ] name

    -d          Delete from .bashrc.' 1>&2;
        return 1;
    fi

    if [ $delete == y ]; then
        sed -i -r "/^mkscreen $name .*/d" $HOME/.bash_screens;
    fi

    unalias $name;

    return 0;
}

