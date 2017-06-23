mdb_environ=$1

[ -z ${mdb_environ} ] && { >&2 echo 'Expected Server branch as parameter'; exit 1; }

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

. build_or_download.sh $e

( [ "$MATRIX_CONFIGURE_REST_ENCRYPTION" == 1 ] && mkdir -p $e*/config_load && cp $e*/configure_rest_encryption.sh $e*/config_load/ ) || :
( [ "$MATRIX_CONFIGURE_INNODB_PLUGIN" == 1 ] && mkdir -p $e*/config_load && cp $e*/configure_innodb_plugin.sh $e*/config_load/ ) || :

./runsuite.sh $e _plugin/xtrabackup/t
)
