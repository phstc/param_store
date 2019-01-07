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
        require_aws_ssm
        Adapters::SSM
      else
        raise "Invalid adapter: #{adapter}"
      end
    end

    private

    def require_aws_ssm
      require 'aws-sdk-ssm'
    rescue LoadError
      fail "aws_ssm requires aws-sdk-ssm to be installed separately. Please add gem 'aws-sdk-ssm' to your Gemfile"
    end
  end
end