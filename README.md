[![CircleCI](https://circleci.com/gh/phstc/param_store.svg?style=svg)](https://circleci.com/gh/phstc/param_store)

# ParamStore

This gem goal is to <strike>DRY some code I have been copying around for a while</strike> make easy switching in between ENV, [AWS Parameter Store (SSM)](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html), [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) and [EJSON](https://github.com/Shopify/ejson) for retrieving parameters.

This gem is not a replacement for [dotenv](https://github.com/bkeepers/dotenv). I still use and recommend it in development, in case it is "safe" to save your keys in `.env` files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'param_store'
```

## Usage

### Configuring adapters

Available adapters: `:env`, `:aws_ssm`, `:aws_secrets_manager` and `:ejson_wrapper`.

```ruby
ParamStore.adapter = adapter
```

### Retrieving parameters

```ruby
# ParamStore.fetch is similar to Hash#fetch,
# If the key is not found and there's no default given, it will raise a `KeyError`
ParamStore.fetch('name')
ParamStore.fetch('name', 'default value')
ParamStore.fetch('name') { 'default value' }
```

### Copying from any adapter to ENV

```ruby
ParamStore.copy_to_env('name1', 'name2', 'name3')

ENV['name1'] # => value for name1
ENV['name2'] # => value for name2
ENV['name3'] # => value for name3
```

## Adapters

### ENV

```ruby
ParamStore.adapter :env
```

### AWS Parameter Store (SSM)

Add to your Gemfile:

```ruby
gem 'aws-sdk-ssm', '~> 1'
```

Configure the adapter:

```ruby
ParamStore.adapter :aws_ssm, default_path: '/Prod/App/DATABASE_URL'
# default_path is optional, but when supplied it is going to be used as prefix for all lookups
# see https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-organize.html
```

#### Retrieving parameters

```ruby
ParamStore.fetch('name')
ParamStore.fetch('name', path: '/Prod/App/DATABASE_URL')
```

#### Copying from SSM adapter to ENV

```ruby
ParamStore.copy_to_env('name1', 'name2', 'name3', path: '/Environment/Type of computer/Application/')
# path overrides default_path

ENV['name1'] # => value for name1
ENV['name2'] # => value for name2
ENV['name3'] # => value for name3
```

#### SSM client

By default ParamStore will initiate `Aws::SSM::Client.new` without supplying any argument. If you want to control the initiation of the SSM client, you can define it by setting `ssm_client`.


```ruby
ParamStore.ssm_client = Aws::SSM::Client.new(
  region: region_name,
  credentials: credentials,
  # ...
)
```

#### CLI

A few useful [aws ssm](https://docs.aws.amazon.com/cli/latest/reference/ssm/index.html) commands:

```sh
aws ssm get-parameters-by-path --path /Prod/ERP/SAP --with-decryption
aws ssm put-parameter --name /Prod/ERP/SAP --value ... --type SecureString
```

### Secrets Manager

Add to your Gemfile:

```ruby
gem 'aws-sdk-secretsmanager', '~> 1'
```

Configure the adapter:

```ruby
ParamStore.adapter :aws_secrets_manager
# ParamStore.fetch('secret') returns a Hash "{\n  \"password\":\"pwd\"\n}\n"

ParamStore.adapter :aws_secrets_manager, default_secret_id: 'secret_id'
# default_secret_id is optional, but when supplied ParamStore.fetch('password') returns a String 'pwd'
```

#### Retrieving parameters

```ruby
ParamStore.fetch('secret_id')
ParamStore.fetch('password', secret_id: 'secret_id')
```

#### Copying from Secrets Manager adapter to ENV

```ruby
ParamStore.copy_to_env('key1', 'key2', 'key3', secret_id: 'secret_id')
# secret_id overrides default_secret_id

ENV['key1'] # => value for key1
ENV['key2'] # => value for key2
ENV['key3'] # => value for key3
```

### EJSON

Add to your Gemfile:

```ruby
gem 'ejson_wrapper', '~> 0.3.1'
```

Configure the adapter:

```ruby
ParamStore.adapter(
  :ejson_wrapper,
  file_path: '...',
  key_dir: '...',
  private_key: '...',
  use_kms: '...',
  region: '...'
)
# see https://github.com/envato/ejson_wrapper#usage
```

#### Rails

If you are using ParamStore in prod and dotenv in dev:

```ruby
# config/application.rb
# Bundler.require(*Rails.groups)
if Rails.env.production?
  ParamStore.adapter(:aws_ssm)
  ParamStore.copy_to_env('DATABASE_URL', require_keys: true, path: '/Prod/MyApp/')
else
  Dotenv::Railtie.load
end
```

### Fail-fast

You can configure the required parameters for an app and fail at startup.

```ruby
# config/application.rb
# Bundler.require(*Rails.groups)
ParamStore.require_keys!('key1', 'key2', 'key3')
# this will raise an error if any key is missing
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
