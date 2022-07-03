#!/bin/bash

# Small script to create notes on why this thing exists
# Funny thing is, I can't remember what I needed to note that prompted me to spend an hour making this

# list of arguments expected in the input
optstring=":hm:d:" # : after letter indicates that we expect an argument
self=$(basename $0)
dir="$PWD" # This gets reset in argparse()

_help() {
    cat<<EOM
    $self usage: 
       -m [message]    Message to input
       -d [directory]  Target directory [ Defaults to CWD ]
       -h              Show this help and exit
    
       Example: 
       $self -m "User message" -d ./project_dir

EOM
}

argparse() {
    while getopts ${optstring} arg; do
      case ${arg} in
      h)
          _help
          exit 0
          ;;
      m)
          message=${OPTARG}
          ;;
      d)
          dir=${OPTARG}
          ;;
      :)
          echo "Option -${OPTARG} requires argument"
          _help
          exit 2
          ;;
      ?)
          _help
          exit 127
          ;;
      esac
    done
    return 0
}

boilerplate() {
    cat<<EOM > "$dir"/NOTE.md
# Created on $(date) by $(whoami)
# Created by $self

User message: $message

EOM
    return 0
}

# Parse arguments
argparse "$@"

if [[ -z "$message" ]]; then
    # We really shouldn't be here
    # TODO: Is this necessary?
    _help
    exit 2
fi

if [[ ! -d "$dir" ]]; then
    echo >&2 "$dir does not exist, exiting"
    exit 3
fi
  
# Create the note
boilerplate
