BRANCH=$1

set -e
echo "clone parent repo and get xtrabackup plugin"
this_repo=$(pwd)
mkdir ../farm
git clone --depth=1 https://github.com/AndriiNikitin/mariadb-environs ../farm
rm -r ../farm/_plugin/xtrabackup
git clone --depth=1 https://github.com/AndriiNikitin/mariadb-environs-xtrabackup ../farm/_plugin/xtrabackup

cd ../farm
./replant.sh m1-${BRANCH}
m1*/checkout.sh
m1*/cmake.sh
m1*/build.sh

( [ "$MATRIX_CONFIGURE_REST_ENCRYPTION" == 1 ] && mkdir -p m1-${BRANCH}/config_load && cp m1*/configure_rest_encryption.sh m1*/config_load/ ) || :
( [ "$MATRIX_CONFIGURE_INNODB_PLUGIN" == 1 ] && mkdir -p m1-${BRANCH}/config_load && cp m1*/configure_innodb_plugin.sh m1*/config_load/ ) || :
  - ./runsuite.sh m1 _plugin/xtrabackup/t

