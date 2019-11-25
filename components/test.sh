#!/bin/bash

container_id=`docker run -d --entrypoint "/bin/sleep" $1 365d`

my_check() {
  docker exec $container_id /bin/sh -c "command -v $1" > /dev/null
}

if my_check dpkg ; then
  echo "dpkg"
elif my_check yum; then
  echo "yum"
elif my_check apk; then
  echo "apk"
fi

docker rm $container_id --force 1>/dev/null
