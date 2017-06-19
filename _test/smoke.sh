arg1=$1
arg2=$2

echo arg1=$arg1
echo arg2=$arg2

( set -o posix ; set ) | grep ^MATRIX_ | while read -r line
do
    echo "$line"
done
