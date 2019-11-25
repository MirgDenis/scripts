#!/bin/bash

if [ -z $1 ]
then
  echo "Dockerimage URL was not provided"
else
  docker pull $1
  container_id=`docker run -d --entrypoint "/bin/sleep" $1 365d`

  my_check() {
    docker exec $container_id /bin/sh -c "command -v $1" > /dev/null
  }

  echo "$1 image consists:"
  if my_check dpkg; then
    # Apt check
    echo -e "\nApt installed packages:"
    docker exec $container_id /bin/sh -c "dpkg -l | grep '^ii' | awk '{print \$2 \" \" \$3}'"
  elif my_check rpm; then
    # Yum check
    echo -e "\nYum installed packages:"
    docker exec $container_id /bin/sh -c "rpm -qa | sed -e 's|.el7||g' -e 's|.x86_64||g' -e 's|.noarch||g' | sed -n 's|-\([0-9]\)| \1|p'"
  elif my_check apk; then
    # Apk check
    echo -e "\nApk installed packages:"
    docker exec $container_id /bin/sh -c "apk info -v 2>/dev/null | sed -n 's|-\([0-9]\)| \1|p'"
  fi

  # Pip check
  pip=`docker exec $container_id /bin/sh -c "find / -name dist-packages -o -name site-packages 2>/dev/null | for i in \\$(cat); do ls \\$i | grep egg-info; done"`
  echo -e "\nPython installed packages:"
  if [ -z "$pip" ]; then
    echo "There are no python packages"
  else
    echo $pip | sed 's|.egg-info||g' | sed -e 's| |\n|1' -e 'P;D' | sed -n 's|-\([0-9]\)| \1|p'
  fi

  # Gem check 
  gem=`docker exec $container_id /bin/sh -c "find / -name gems 2>/dev/null | for i in \\$(cat); do ls \\$i | grep -; done"`
  echo -e "\nGem installed packages:"
  if [ -z "$gem" ]; then
    echo "There are no gem packages"
  else
    echo $gem | sed -e 's| |\n|1' -e 'P;D' | sed -n 's|-\([0-9]\)| \1|p'
  fi

  docker rm $container_id --force 1>/dev/null 
  
  # Labels check
  labels=`docker inspect $1 | grep -m1 external_components | cut -d ':' -f 2 | awk -F'[][," ]+' '{for (i=2; i<NF; i++) print $i}' | tr -d \'`
  echo -e "\nComponents which were added via flavors, usually they are built from source:"
  if [ -z "$labels" ]; then
    echo "There are no labels"
  else
    echo $labels | sed -e 's| |\n|2' -e 'P;D'
  fi

  docker image rm $1 --force
fi 
