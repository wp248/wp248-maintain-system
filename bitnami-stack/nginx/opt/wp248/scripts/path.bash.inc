
function is_file() {
local file=$1
[[ -f $file ]]
}

function is_dir() {
local dir=$1
[[ -d $dir ]]
}

path_append() {
for ARG in "$@"
do
if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
export PATH="${PATH:+"$PATH:"}$ARG"
fi
done
}

path_prepend() {
for ((i=$#; i>0; i--));
do
ARG=${!i}
if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
export PATH="$ARG${PATH:+":$PATH"}"
fi
done
}

#path_append $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
path_append /opt/wp248/scripts
