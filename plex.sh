#!/bin/bash

# Copyright 2019 Ryan Oberlin
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


###################################################################################
# Simple script to correct permissions on my plex media directory
# Recommeded to use with crontab: 
# 15 */12 * * * /usr/bin/bash /home/$user/plex.sh 2>&1 >> /home/$user/.plex.log

# Setting variables

MEDIADIR="/Media/"
FILE_PERM=$FILE_PERM
DIR_PERM=$DIR_PERM

_stat () {
	stat -c %a "$1"
	return
}

_ustat () {
	stat -c %U:%G "$1"
	return
}

_date () {
        echo -n "$(date +%D\ :\ %H:%M:%S\ :)"
}


_fixperm () {
	if [[ -f "$1" ]] && [[ $(_stat "$1" ) != $FILE_PERM ]]; then
		echo "$(_date) Incorrect permissions on file: ${1}"
		chmod $FILE_PERM "$1"
	elif [[ -d "$1" ]] && [[ $(_stat "$1" ) != $DIR_PERM ]]; then
		echo "$(_date) Incorrect permissions on directory: ${1}"
		chmod $DIR_PERM "$1"
	elif [[ -e "$1" ]] && [[ $(_ustat "$1" ) != plex:plex ]]; then
		echo "$(_date) Incorrect ownership: ${1}"
		chown plex:plex "$1"
	fi
}

# Exporting our functions so we can access them through our `find -exec` subshell
export -f _fixperm
export -f _stat
export -f _ustat
export -f _date

find $MEDIADIR -exec bash -c '_fixperm "$0"' {} \;
