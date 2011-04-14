function find-js-func
{
    egrep -inR 'function\s+\S*'"$1"'\S*\(' . | grep -v '^Binary';
}

function find-cs-class
{
    egrep -inR '(:?class|struct)\s+\S*'"$1" . | grep -v '^Binary';
}

function find-cs-func
{
    egrep -inR '(:?public|protected|private)\s+\S+\s+\S*'"$1"'\S*\s*\(' . | \
            grep -v '^Binary';
}

function killflash
{
    flashpids=`flashpids`;
    if [ "$flashpids" == "" ]; then
        echo "Can't get flash PIDs... :(" 1>&2;
    fi
    kill -KILL "`flashpids`";
    #killall -q nsplugin
}

function killall
{
    while [ "$1" ]; do
        process="$1"

        if [ "$process" == -f -o "$process" == --force ]; then
            force=1
            continue;
        fi

        psaux="`ps aux | grep "$process" | grep -v grep`";
        pids="`echo "$psaux" | awk '{print $2}' | xargs`";

        echo "$psaux";

        if [ ! "$force" ]; then
            echo "The following PIDs will be KILLed: $pids";
            read -p "Terminate these processes (Y/n) [n] " answer;
            if [ "$answer" == y -o "$answer" == Y ]; then
                echo "KILLing..."
                kill -KILL $pids
            else
                echo "Skipping /$process/";
            fi;
        fi
    done
}

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

