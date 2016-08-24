# Rack::Cache::Monitor

The rack-cache-monitor middleware lets you monitor rack-cache and reports related stats, such as the number of fresh hits, passes, or its hitrate. 
Behind the scenes it simply counts `Rack::Cache` traces and yields its results to a user defined _reporter_ on a configurable interval.
It is designed to work in the context of threaded and multi-process web servers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-cache-monitor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-cache-monitor

## Usage

`Rack::Cache::Monitor` is a Rack middleware and must be inserted into the middleware stack _before_ `Rack::Cache`. Its constructor takes a block which acts as the reporter.

### Basic

```ruby
# In rackup file:
require 'rack/cache'
require 'rack/cache/monitor'

use Rack::Cache::Monitor, **options do |report|
  STDOUT.puts "Rack::Cache hitrate: #{report.hitrate}%" if report.hitrate
end

use Rack::Cache #, ....

run app
```

### With Rails

```ruby
# In environment config file:
config.middleware.insert_before "Rack::Cache", "Rack::Cache::Monitor", **options do |report|
  STDOUT.puts "Rack::Cache hitrate: #{report.hitrate}%" if report.hitrate
end
```

## Options

<dl>
    <dt><tt>:interval_in_seconds</tt></dt>
    <dd>Stats are flushed and reported on this interval. In seconds. Default is 30.</dd>

    <dt><tt>:log_level</tt></dt>
    <dd>Log level of the default logger.</dd>

    <dt><tt>:logger</tt></dt>
    <dd>Custom logger object. The default logger writes to <tt>STDOUT</tt>.</dd>

    <dt><tt>:report_on_exit</tt></dt>
    <dd>Flush and report one more time before the program / web server exits. Default is <tt>true</tt>.</dd>
</dl>

## Things to know

- When an exception is raised from the reporter block, the exception is logged and the monitor is gracefully shut down. The web server continues to run without `Rack::Cache` monitoring.
- The reporter block is called in a plain Ruby thread. If you're on a GIL-enabled Ruby you might want to avoid doing anything expensive other than IO operations, as it may slow down your application.
- The interval starts _after_ the reporter is finished handling a report. I.e. if your reporter takes 30 seconds to do its job, and the interval is also set to 30 seconds, then the reporter is called only once a minute.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/s-andringa/rack-cache-monitor.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

