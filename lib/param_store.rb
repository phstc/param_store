require 'forwardable'

require 'param_store/version'
require 'param_store/wrapper'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'
require 'param_store/adapters/secrets_manager'
require 'param_store/adapters/ejson_wrapper'

module ParamStore
  extend SingleForwardable

  def_delegators(
    :'@wrapper',
    :fetch,
    :copy_to_env,
    :require_keys!
  )

  class << self
    attr_reader :adapter, :wrapper
    attr_writer :ssm_client, :secrets_manager_client

    def ssm_client
      @ssm_client ||= Aws::SSM::Client.new
    end

    def secrets_manager_client
      @secrets_manager_client ||= Aws::SecretsManager::Client.new
    end

    def adapter(adapter, **opts)
      @adapter = adapter
      @wrapper = Wrapper.new(adapter_class(adapter), **opts)
    end

    def adapter_class(adapter)
      case adapter
      when :env
        Adapters::Env
      when :aws_ssm
        require_adapter_dependency(adapter, 'aws-sdk-ssm')
        Adapters::SSM
      when :aws_secrets_manager
        require_adapter_dependency(adapter, 'aws-sdk-secretsmanager')
        Adapters::SecretsManager
      when :ejson_wrapper
        require_adapter_dependency(adapter, 'ejson_wrapper')
        Adapters::EJSONWrapper
      else
        raise "Invalid adapter: #{adapter}"
      end
    end

    private

    def require_adapter_dependency(adapter, dependency)
      require dependency
    rescue LoadError
      fail "#{adapter} requires #{dependency} to be installed separately. Please add gem '#{dependency}' to your Gemfile"
    end
  end
end