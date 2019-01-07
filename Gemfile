source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in param_store.gemspec
gemspec

group :development, :test do
  gem 'aws-sdk-ssm', '~> 1'
  gem 'ejson_wrapper', '~> 0.3.1'
  gem 'pry-byebug'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'rspec_junit_formatter'
  gem 'stub_env'
end