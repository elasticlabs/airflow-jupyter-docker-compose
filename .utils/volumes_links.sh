#!/usr/bin/env bash
#
# This script :
#    - creates a .volumes local directory
#    - initializes a .gitignore file preventing git interaction with data volumes
#    - creates symbolic links between named volumes and volumes sub-directories

# Args
actionType=$1
volDirPath=$2
projectName=$3
volumesList=$4

case "$actionType" in
    "build")
        #
        # Create if not exist the ".volumes" directory
        ./message.sh info "[INFO] Create the .volumes directory if required"
        [ ! -d ${volDirPath}.volumes ] && echo mkdir -p ${volDirPath}.volumes \ 
            && chmod 755 ${volDirPath}.volumes \
            && ./message.sh info "[INFO] creation OK"
        #
        ./message.sh info "[INFO] tell GIT to ignore it if not already"
        ignoreFlag=`cat .gitignore | grep .volumes`
        [ -z "$ignoreFlag" ] && echo ".volumes" >> .gitignore

        #
        # Create sub-directories as symlinks for the following volumes
        ./message.sh info "[INFO] Create the following .volumes/* director(y|ies) :"
        ./message.sh info "$volumesList"
        for vol in `echo $volumesList`
            do 
                volName=`docker volume inspect ${projectName}_${vol} --format '{{ .Mountpoint }}'`
                ln -s ${volName} .volumes/${vol}
                ./message.sh link "${projectName}_${vol} volume -> .volumes/${vol}"
            done
    ;;
    "save")
        # Application of the official procedure :
        #   -> https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes
        # 
        # We create a tar archive of volumes inside the container, then move it to SVG directory then 
        # delete the archive inside the container.
        ./message.sh info "[INFO] Save all volumes content into ${volDirPath} parent dir..."
        for vol in `echo $volumesList`
            do
                ./message.sh warning "TODO in future versions"
            done
    ;;
esac



