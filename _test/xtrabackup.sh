mdb_environ=$1
xb_environ=$2

[ -z ${mdb_environ} ] && { >&2 echo 'Expected Server branch as parameter'; exit 1; }
[ -z ${xb_environ} ] && { >&2 echo 'Expected Xtrabackup version as parameter'; exit 1; }

set -e

if [ ! -d farm ] ; then
  echo "clone parent repo and get xtrabackup plugin"
  mkdir farm
  git clone --depth=1 https://github.com/AndriiNikitin/mariadb-environs farm
else
  (cd farm && git pull)
fi

(
set -e
cd farm
./get_plugin.sh xtrabackup
e=$(./reuse_or_plant_m.sh ${mdb_environ})
x=$(./reuse_or_plant_x.sh ${xb_environ})

. build_or_download.sh $e
. build_or_download.sh $x

( [ "$MATRIX_CONFIGURE_INNODB_PLUGIN" == 1 ] && mkdir -p $e*/config_load && cp $e*/configure_innodb_plugin.sh $e*/config_load/ ) || :

./runsuite.sh $e $x _plugin/xtrabackup/t
)
