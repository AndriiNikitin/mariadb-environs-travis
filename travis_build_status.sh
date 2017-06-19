
build_id=$1

if [ -z "$build_id" ] ; then
  >&2 echo "Expected build id as first parameter"
  exit 1
fi

repo=13123932
header=' -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Travis-API-Version: 3" '

build_details="$(curl -s -X GET $header https://api.travis-ci.org/v3/build/$build_id)"

build_status=$(echo "$build_details" | grep state | head -n 1)
# remove prefix before colon
build_status=${build_status#*:}
# remove last comma
build_status=${build_status%%,}
# remove wrapping quotes
build_status=${build_status//\"}

echo $build_status
