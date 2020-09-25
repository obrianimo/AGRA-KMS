#!/bin/sh
source /usr/local/rvm/environments/ruby-2.5.1
/usr/local/rvm/gems/ruby-2.5.1/bin/rails server --environment=development > rails.log 2>&1 &
#rails server --environment=development > rails.log 2>&1 &

