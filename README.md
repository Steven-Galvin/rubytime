# Rubytime


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubytime', git: 'https://www.github.com/tenebrousedge/rubytime.git'
```

And then execute:

    $ bundle

## Usage

In order to get the database set up, you need to create a postgresql user account for the test database, and one for the live database as well.

    $ sudo -u postgres createuser rubytime -p
    $ sudo -u postgres createuser rubytime_test -p

> Note:
Passwords are required unless you want to [reconfigure postgres](http://stackoverflow.com/questions/23375740/pgconnectionbad-fe-sendauth-no-password-supplied).

Then you can create the necessary tables by running:

    $ sudo -u postgres psql -d postgres -f ./scripts/create_databases.sql
    $ rake db:migrate
    $ RACK_ENV='test' rake db:migrate

You will also need to edit the env.example file to contain the correct username and password for your postgres users, and rename it to `.env`.

Finally, start the app by running `rackup`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubytime.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

