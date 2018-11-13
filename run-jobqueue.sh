#!/bin/sh
rbenv local 2.5.1

echo Starting Redis
redis-server /usr/local/etc/redis.conf --loglevel warning > redis.log 2>&1 &
echo Start Sidekiq
bundle exec sidekiq > sidekiq.log 2>&1 &

echo Done.
