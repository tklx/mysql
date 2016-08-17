## Install dependencies

```console
git clone https://github.com/tklx/bats.git
bats/install.sh /usr/local
```

## Run the tests

```console
IMAGE=tklx/mysql bats --tap tests/basics.bats

init: running tklx/mysql
init: waiting for tklx/mysql to accept connections.......
1..10
ok 1 create table
ok 2 new table is empty
ok 3 test insert
ok 4 count after insert is 1
ok 5 test insert 2
ok 6 count after insert 2 is 2
ok 7 test conditional delete
ok 8 count after delete is 1
ok 9 test select
ok 10 test drop table
```

