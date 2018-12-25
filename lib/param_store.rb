require 'aws-sdk-ssm'

require 'param_store/version'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'

module ParamStore
  class << self
    attr_reader :ssm_client

    def ssm_client
      ssm_client ||= Aws::SSM::Client.new
    end
  end
end