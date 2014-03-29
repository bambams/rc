#!/bin/bash

cd "$(dirname "$0")" || exit 1;

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
all_files=(`ls -d .* *`);

ignored_files=(
        .
        ..
        .git
        .gitignore
        .netrc
        bin
        install.sh
        offlineimap.conf
        README
        vs2010.vssettings
        vs2012.vssettings
        );

function resolve-rc-path
{
    local home_dir="$1";
    local rc_dir="$2";

    # h4x; arbitrarily using bash for script, but sneaking in some
    # Perl. ^^
    if perl -E "exit 0 if (\$_ = '${rc_dir}') =~ q'${home_dir}';exit 1;"; then
        perl -E "(\$_ = '${rc_dir}') =~ s,^${home_dir}/,,;say";
    else
        echo "${rc_dir}";
    fi;
}

rc_dir="$(resolve-rc-path "${HOME}" "${script_dir}")";

for f in "${all_files[@]}"; do
    ignored=;
    for g in "${ignored_files[@]}"; do
        if [ "$f" == "$g" ]; then
            ignored=1;
            break;
        fi;
    done;

    if [ -z "${ignored}" ]; then
        ln -s "${rc_dir}/$f" "${HOME}";
    fi;
done;

mkdir -p "$HOME/bin";
ln -s "../${rc_dir}/bin/git-ps1__" "$HOME/bin/";

# Install into .bashrc.
if [ "$1" == "-f" ] &&
        ! grep '^\s*(\.|source)\s*(~|$HOME)/.bash.d.source' ~/.bashrc;
        then
    cat <<-'EOF' >> ~/.bashrc;
	
	# Source the awesomeness.
	source ~/.bash.d.source
EOF
fi;
