#!/bin/bash

###### CONFIG ############

candidate_artifacts=( "webapp" )
servers=( "localhost" "node1" "node2" "node3")
prod_servers=( "node1" "node2" "node3")
server_postfix=".bekkopen.no"
user="bekkopen"
startup_script="startup.sh"
deploy_script="deploy.sh"
monitor_script="server_monitor.sh"
scripts_dir="../scripts"
config_file="deploy.config"
config_dir="../config"

###### FUNCTIONS #########

upload_file() {
  local server=$1
  local file=$2
  local target=$3
  if [ -f $file ]; then
    upload="scp $file $server:$target"
    echo Running $upload
    eval $upload
    if [ "$?" -ne "0" ]; then
      echo "The command $upload failed! Quitting ..."
      exit 800
    fi
  else
    echo "File $file not found!"
    exit 801
  fi
}

function contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
    if [ "${!i}" == "${value}" ]; then
      echo "y"
      return 0
    fi
  }
  echo "n"
  return 1
}

##########################

if [ $# -lt 1 ]; then
   echo 1>&2 "At least one server must be given as parameter. Usage: $0 [<server> ...]"
   echo 1>&2 "Legal parameters: ${servers[@]}"
   exit 802
fi

parameters=( $@ )

for i in $*
do
  if [ $(contains "${servers[@]}" $i) == "n" ]; then
    echo "Illegal server: $i"
    exit 803
  fi
done

version="`grep artifactId.*parent ../pom.xml -A1 | grep version | sed -E 's/.*<version>(.*)<\/version>/\1/'`"
read -p "Versjon? [$version] " input_version
if [ $input_version ]; then
  version=$input_version
fi
while true; do
    read -p "Do you want to upload from local machine? " yn
    case $yn in
      [Yy]* ) deploy_from_local_files="true"
      break;;
      [Nn]* ) deploy_from_local_files="false"
      break;;
      * ) echo "You must type yes or no.";;
    esac
done
if [ "true" == $deploy_from_local_files ]; then
  while true; do
    read -p "Have you remembered to run mvn clean install? " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "You must type yes or no.";;
    esac
  done
fi

declare -a artifacts
for artifact in ${candidate_artifacts[@]}
do
while true; do
      read -p "Do you wish to deploy $artifact? " yn
      case $yn in
        [Yy]* ) artifacts[$[${#artifacts[@]}+1]]=$artifact
        break;;
        [Nn]* )
        break;;
        * ) echo "You must type yes or no.";;
      esac
  done
done

if [ ${#artifacts[@]} -eq 0 ]; then
  echo "You have to choose at least one artifact!"
  exit 0;
fi

echo Deploying: ${artifacts[@]}

targets=${parameters[@]}
declare -a deploy_cmds

for target in ${targets[@]}
do
  if [ $(contains "${servers[@]}" $target) == "y" ]; then
    server=$target
    if [ $(contains "${prod_servers[@]}" $target) == "y" ]; then
      server=$server$server_postfix
    fi
  else
    echo "$target is invalid! Quitting ..."
    exit 804
  fi
  server_host="$user@$server"
  if [ "true" == $deploy_from_local_files ]; then
    upload_file $server_host $scripts_dir/$target/$startup_script ./
    upload_file $server_host $scripts_dir/$target/$deploy_script ./
    upload_file $server_host $scripts_dir/$target/$monitor_script ./
    upload_file $server_host $config_dir/$target/$config_file ./
    for artifact in ${artifacts[@]}
    do
      upload_file $server_host "../$artifact/target/$artifact-$version.zip" ./
      cmd="ssh -tt $server_host \"nohup ./deploy.sh $artifact $version > /dev/null 2>&1 </dev/null\""
      echo "Running: $cmd"
      eval $cmd
      response=$?
      if [ $response -ne 0 ]; then
        echo "$cmd failed with exit code $response Quitting ..."
        exit 805
      fi
    done
  fi
done
