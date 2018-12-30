[![CircleCI](https://circleci.com/gh/phstc/param_store.svg?style=svg)](https://circleci.com/gh/phstc/param_store)

# ParamStore

This gem goal is to <strike>DRY some code I have been copying around for a while</strike> make easy switching in between ENV and [AWS Parameter Store (SSM)](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html) for retrieving parameters.

This gem is not a replacement for [dotenv](https://github.com/bkeepers/dotenv). I still use and recommend it in development, in case it is "safe" to save your keys in `.env` files. Otherwise, you could also use AWS Parameter Store for development.


**ParamStore works, but it is still under development, future PATCH releases may introduce breaking changes. Once the interface is figured out, this gem will follow [Semantic Versioning](https://semver.org/).**


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'param_store'
```

## Usage

For switching in between ENV and SSM, you need you set which adapter you want to use.

```ruby
# read from SSM
# i.e. config/environments/production.rb
ParamStore.adapter :aws_ssm, default_path: '/Dev/App/SecretKey'
# default_path is optional, but when supplied it is going to be used as prefix for all lookups
# see https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-organize.html

# read from ENV
# i.e. config/environments/[development, test].rb
ParamStore.adapter :env
```

For retrieving parameters:

```ruby
# fetch is similar to Hash#fetch,
# if the key is not found and there's no default defined, it raises an error
ParamStore.fetch('my_secret_key')
```

### SSM to ENV

You can also make SSM compatible with `ENV` by copying parameters to `ENV`.

```ruby
ParamStore.copy_to_env('key1', 'key2', 'key3')
ParamStore.copy_to_env('key1', 'key2', 'key3', path: '/Environment/Type of computer/Application/')
# path overrides default_path

ENV['key1'] # => value for key1
ENV['key2'] # => value for key2
ENV['key3'] # => value for key3
```

#### Rails

If you are using ParamStore in prod and dotenv in dev:

```ruby
# config/application.rb
# Bundler.require(*Rails.groups)
if Rails.env.production?
  ParamStore.adapter(:aws_ssm)
  ParamStore.copy_to_env('MONGOHQ_URL', require_keys: true, path: '/Prod/MyApp/')
else
  Dotenv::Railtie.load
end
```


### SSM client

By default ParamStore will initiate `Aws::SSM::Client.new` without supplying any parameter. If you want to control the initiation of the SSM client, you can define it by setting `ssm_client`.


```ruby
ParamStore.ssm_client = Aws::SSM::Client.new(
  region: region_name,
  credentials: credentials,
  # ...
)
```

### Fail-fast

You can configure the required parameters for an app and fail at startup.

```ruby
# config/application.rb
# Bundler.require(*Rails.groups)
ParamStore.require_keys!('key1', 'key2', 'key3')
# this will raise an error if any key is missing
```

#### aws ssm

A few useful [aws ssm](https://docs.aws.amazon.com/cli/latest/reference/ssm/index.html) commands:

```sh
aws ssm get-parameters-by-path --path /Prod/ERP/SAP --with-decryption
aws ssm put-parameter --name /Prod/ERP/SAP --value ... --type SecureString
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phstc/param_store. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ParamStore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/phstc/param_store/blob/master/CODE_OF_CONDUCT.md).
