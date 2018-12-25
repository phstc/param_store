source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in param_store.gemspec
gemspec

group :development, :test do
  gem 'pry-byebug'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'rspec_junit_formatter'
  gem 'stub_env'
end
