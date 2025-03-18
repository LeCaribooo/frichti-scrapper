# Use this file to easily define all of your cron jobs.
#
# Learn more: http://github.com/javan/whenever

# Set the environment (optional)
# set :environment, 'development'

# Set the output log for whenever
set :output, 'log/cron.log'

# Run every 10 minutes, but only between 11:00-11:59 AM
every '*/10 11 * * *' do
  rake 'frichti:search_kebab'
end