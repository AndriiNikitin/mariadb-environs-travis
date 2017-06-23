branch=$1

[ -z ${branch} ] && { >&2 echo 'Expected server branch as parameter }'

export travis_command="bash -xv _test/mariabackup.sh ${branch}"
export travis_env_matrix='"MATRIX_CONFIGURE_REST_ENCRYPTION=0","MATRIX_CONFIGURE_REST_ENCRYPTION=1","MATRIX_CONFIGURE_REST_ENCRYPTION=0 MATRIX_CONFIGURE_INNODB_PLUGIN=1","MATRIX_CONFIGURE_REST_ENCRYPTION=1 MATRIX_CONFIGURE_INNODB_PLUGIN=1"'

. travis_build_submit.sh
