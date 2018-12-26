require 'aws-sdk-ssm'
require 'forwardable'

require 'param_store/version'
require 'param_store/wrapper'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'

module ParamStore
  extend SingleForwardable

  def_delegators(
    :'@wrapper',
    :fetch,
    :copy_to_env,
    :require_keys!
  )

  class << self
    attr_accessor :path
    attr_reader :adapter, :wrapper

    def ssm_client
      @_ssm_client ||= Aws::SSM::Client.new
    end

    def adapter=(adapter)
      @adapter = adapter
      @wrapper = Wrapper.new(adapter_class(adapter))
    end

    def adapter_class(adapter)
      case adapter
      when :env
        Adapters::Env
      when :aws_ssm
        Adapters::SSM
      else
        raise "Invalid adapter: #{adapter}"
      end
    end
  end
end