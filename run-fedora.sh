#!/bin/sh
# jenv local 1.8
# rbenv local 2.5.1
echo Starting fcrepo
fcrepo_wrapper --config `pwd`/.fcrepo_wrapper  > fedora.log 2>&1 &
echo Done.
