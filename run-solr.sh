#!/bin/sh
# jenv local 1.8
# rbenv local 2.5.1
echo Starting Solr
solr_wrapper -v --config `pwd`/.solr_wrapper > solr.log 2>&1 &
echo Done.
