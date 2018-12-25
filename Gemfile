source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in param_store.gemspec
gemspec

group :development, :test do
  gem 'pry-byebug'
end

group :test do
  gem 'stub_env'
  gem 'rspec_junit_formatter'
  gem 'rspec', '~> 3.0'
end
