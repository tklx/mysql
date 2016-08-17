# based on: docker-library/official-images/test/tests/mysql-basics/run.sh

fatal() { echo "fatal [$(basename $BATS_TEST_FILENAME)]: $@" 1>&2; exit 1; }

_in_cache() {
    IFS=":"; img=($1); unset IFS
    [[ ${#img[@]} -eq 1 ]] && img=("${img[@]}" "latest")
    [ "$(docker images ${img[0]} | grep ${img[1]} | wc -l)" = "1" ] || return 1
}

[ "$IMAGE" ] || fatal "IMAGE envvar not set"
_in_cache $IMAGE || fatal "$IMAGE not in cache"

mysql() {
    docker run --rm -i \
        --link "$CNAME":mysql \
        --entrypoint mysql \
        -e MYSQL_PWD="$MYSQL_PASSWORD" \
        "$IMAGE" \
        -hmysql \
        -u"$MYSQL_USER" \
        --silent \
        "$@" \
        "$MYSQL_DATABASE"
}

_init() {
    export TEST_SUITE_INITIALIZED=y

    echo >&2 "init: running $IMAGE"

    export MYSQL_ROOT_PASSWORD='this is an example test password'
    export MYSQL_USER='0123456789012345' # (should be no longer than 16)
    export MYSQL_PASSWORD='my cool mysql password'
    export MYSQL_DATABASE='my cool mysql database'

    export CNAME="mysql-$RANDOM-$RANDOM"
    export CID="$(docker run -d --name "$CNAME" -e MYSQL_ROOT_PASSWORD -e MYSQL_USER -e MYSQL_PASSWORD -e MYSQL_DATABASE "$IMAGE")"
    [ "$CIRCLECI" = "true" ] || trap "docker rm -vf $CID > /dev/null" EXIT

    echo -n >&2 "init: waiting for $IMAGE to accept connections"
    tries=10
    while ! echo 'SELECT 1;' | mysql &> /dev/null; do
        (( tries-- ))
        if [ $tries -le 0 ]; then
            echo >&2 "$IMAGE failed to accept connections in wait window!"
            ( set -x && docker logs "$CID" ) >&2 || true
            false
        fi
        echo >&2 -n .
        sleep 2
    done
    echo

}
[ -n "$TEST_SUITE_INITIALIZED" ] || _init

@test "create table" {
    echo 'CREATE TABLE test (a INT, b INT, c VARCHAR(255))' | mysql
    [ $? -eq 0 ]
}

@test "new table is empty" {
    [ "$(echo 'SELECT COUNT(*) FROM test' | mysql)" = 0 ]
}

@test "test insert" {
    echo 'INSERT INTO test VALUES (1, 2, "hello")' | mysql
    [ $? -eq 0 ]
}

@test "count after insert is 1" {
    [ "$(echo 'SELECT COUNT(*) FROM test' | mysql)" = 1 ]
}

@test "test insert 2" {
    echo 'INSERT INTO test VALUES (2, 3, "goodbye!")' | mysql
    [ $? -eq 0 ]
}

@test "count after insert 2 is 2" {
    [ "$(echo 'SELECT COUNT(*) FROM test' | mysql)" = 2 ]
}

@test "test conditional delete" {
    echo 'DELETE FROM test WHERE a = 1' | mysql
    [ $? -eq 0 ]
}

@test "count after delete is 1" {
    [ "$(echo 'SELECT COUNT(*) FROM test' | mysql)" = 1 ]
}

@test "test select" {
    [ "$(echo 'SELECT c FROM test' | mysql)" = 'goodbye!' ]
}

@test "test drop table" {
    echo 'DROP TABLE test' | mysql
}
