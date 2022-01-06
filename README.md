# Cocoro

Cocoro is a Ruby gem for controlling some of SHARP's air purifiers and humidifiers that you can normally control using Cocoro Air mobile apps.
The gem uses the same API that the mobile apps do, except it's totally unofficial, unsupported and not affiliated with SHARP in any way.
The moment they change the APIs the gem may break completely, so use it at your own risk.

I've only tested this on SHARP KI-LS70.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cocoro'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cocoro

## Getting the API credentials

You do need to use the official Cocoro Air mobile app first, register your device etc.
Once you've done that, you need to find out what _app secret_ and _terminal app id key_ your Cocoro Air mobile app is using.
To do that, you'll have to look inside the HTTPS requests that it's making. You can use
[mitmproxy](https://mitmproxy.org/) (or any other dev proxy with SSL support, like [Charles Proxy](https://www.charlesproxy.com/)).
On Android there'll be another obstacle - you'll need to modify the apk to allow user added CA certificates.

My app secret is 43 alphanumeric characters followed by a `=` and my terminal app id key is 43 alphanumeric characters.

## Usage

First use the credentials to log in, get a list of your devices and choose the one you want to control:

```ruby
cocoro = Cocoro::Client.new(
  app_secret: 'REPLACE_WITH_YOUR_CREDENTIALS',
  terminal_app_id_key: 'REPLACE_WITH_YOUR_CREDENTIALS'
)
cocoro.login
device = cocoro.devices.first
```

Now you can do various things like:
```ruby
device.fetch_status!.air_volume # => 'medium'
device.set_air_volume!('quiet')
device.fetch_status!.air_volume # => 'quiet'
device.fetch_status!.to_h # => a hash of all the latest status information
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spect88/cocoro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Similar projects

The only similar project I'm aware of is the [python cocoro module](https://github.com/rcmdnk/cocoro).
At the time of writing this, the python module can't display any status information like current temperature/humidity.
