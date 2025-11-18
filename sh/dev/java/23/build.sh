#!/bin/bash


_SILENT_JAVA_OPTIONS="$_JAVA_OPTIONS"
unset _JAVA_OPTIONS
alias java='java "$_SILENT_JAVA_OPTIONS"'


git clone https://github.com/openjdk/jdk23u && cd jdk23u

# _JAVA_OPTIONS = ""

bash configure

sudo apt-get install autoconf

make images


.build/*/images/jdk/bin/java -version

make test-tier1