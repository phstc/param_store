require 'aws-sdk-ssm'
require 'aws-sdk-secretsmanager'
require 'forwardable'

require 'param_store/version'
require 'param_store/wrapper'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'
require 'param_store/adapters/secrets_manager'

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
        Adapters::SSM
      when :aws_secrets_manager
        Adapters::SecretsManager
      else
        raise "Invalid adapter: #{adapter}"
      end
    end
  end
end