#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
all_files=(`ls -d .*`);
ignored_files=(. .. .git .gitignore offlineimap.conf);

function resolve_rc_path
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

rc_dir="$(resolve_rc_path "${HOME}" "${script_dir}")";

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

