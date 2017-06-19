travis_matrix_script=${travis_matrix_script-'test/smoke.sh'}
travis_env_global=${travis_env_global-'BRANCH=10.1'}
travis_env_matrix=${travis_env_matrix-''}
travis_repo=${travis_repo-13966407}

header=' -H "Content-Type: application/json" -H "Accept: application/json" -H "Travis-API-Version: 3"'

body='{
 "request": {
 "message": "Trigger '$matrix_script' with '${travis_env_global}'",
 "branch":"master",
 "config": {
   "env": {"global": ["'${travis_env_global}'"],
           "matrix": ["'${travis_env_matrix}'"]}
  }
  "script":"${travis_script}"
}}'

tracing_was_set=0
if [[ $(shopt -p xtace) ~=  on ]]  ; then
  >&2 echo temporarily disabling bash tracing to hide travis token
  tracing_was_set=1
  set +x
fi

function post_job {

[ -f .travis.token ] && travis_token=$(cat .travis.token)
[ -f .${travis_repo}.token ] && travis_token=$(cat .${travis_token}.token )

curl -s -X POST $header \
 -H "Authorization: token $(cat .travis.token)" \
 -d "$body" \
 https://api.travis-ci.org/repo/$repo/requests
}

request_result="$(post_job)"

unset travis_token
[ ${tracing_was_set}==0 ] || set -x

# this should return     "id": 444444,
request_id=$(echo "${request_result}" | grep '"id":' | tail -n 1 )
# this should return     444444,
request_id=${request_id#*:}
# cut last comma
request_id=${request_id%%,}
# remove evt. spaces
request_id=${request_id//[[:space:]]/}

if [ -z $request_id ] ; then
  >&2 echo "couldn't parse request_id: $request_result"
  exit 1
fi

request_details="$(curl -s -X GET $header https://api.travis-ci.org/v3/repo/$repo/request/$request_id)"

commit_id=$(echo "$request_details"| grep -A 10 '"commit": {' | grep  '"id":' | head -n 1)
commit_id=${commit_id#*:}
commit_id=${commit_id%%,}
commit_id=${commit_id//[[:space:]]/}

if [ -z "$commit_id" ] ; then
  >&2 echo "couldn't parse commit_id: $request_details"
  exit 1
fi

builds="$(curl -s -X GET $header https://api.travis-ci.org/v3/repo/$repo/builds)"

build_id=$(echo "$builds" | grep -B 50 $commit_id | grep -A20 '"build"' | grep '"id":' | head -n 1)
build_id=${build_id#*:}
build_id=${build_id%%,}
build_id=${build_id//[[:space:]]/}

if [ -z "$build_id" ] ; then
  >&2 echo "couldn't parse build_id: $build_details"
  exit 1
else
  echo $build_id
fi

