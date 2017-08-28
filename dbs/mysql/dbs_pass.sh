#!/bin/bash

if [[ `uname` == 'Darwin' ]]; then
    export TF_VAR_dbs_pass="$(security find-generic-password -a dbs_pass -w)"
elif [[ `uname` == 'Linux' ]]; then
    export TF_VAR_dbs_pass="$(dbs_pass)"
fi
