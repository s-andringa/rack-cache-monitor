# Rack::Cache::Monitor

The rack-cache-monitor middleware lets you monitor rack-cache related stats, such as the number of fresh hits, passes, or its hitrate, and report them the way you want.

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

```ruby
use Rack::Cache::Monitor do |report|
  STDOUT.puts "Rack::Cache hitrate: #{report.hitrate}%" if report.hitrate
end
use Rack::Cache
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/s-andringa/rack-cache-monitor.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

