
#!/bin/bash

source qm.variables
source lib/common.sh

function getTag() {
    local __tag=$1
    local __defaultVal=$2
    local __resultvar=$3

    if [ $__tag = "development" ]; then
        __newValue="Dev"
    elif [ $__tag = "master" ]; then
        __newValue=$__defaultVal
    elif [[ $__tag == V* ]] || [[ $__tag == v* ]]; then
        __newValue=$(echo $__tag | cut -c 2-)
    else
        __newValue=$__tag
    fi

    eval $__resultvar="'$__newValue'"
}

if [ ! -z "$1" ]; then
    dockerImage=$1
fi

if [ ! -z "$2" ]; then
    tagname=$2
else

    branch=$(git branch | grep \* | cut -d ' ' -f2-)


    getTag $powerchain_version 2.0.2 powerchain_version

    getTag $branch $powerchain_maker_version powerchain_maker_version

    tagname=$powerchain_version"_"$powerchain_maker_version
fi

dockername=$dockerImage":"$tagname
echo $CYAN"Building image, "$dockername"..."$COLOR_END

lib/install_powerchain.sh
lib/install_tessera.sh
lib/build_nodemanager.sh
lib/build_ui.sh


docker build --no-cache -t $dockername .
