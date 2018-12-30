require 'aws-sdk-ssm'
require 'ejson_wrapper'
require 'forwardable'

require 'param_store/version'
require 'param_store/wrapper'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'
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

    def ssm_client
      @_ssm_client ||= Aws::SSM::Client.new
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
      when :ejson_wrapper
        Adapters::EJSONWrapper
      else
        raise "Invalid adapter: #{adapter}"
      end
    end
  end
end