#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR/flexget

flexget -c config.yml $@
