require 'aws-sdk-ssm'

require 'param_store/version'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'

module ParamStore
  class << self
    attr_accessor :cache, :path
    attr_writer :adapter_instance
    attr_reader :adapter

    def ssm_client
      @_ssm_client ||= Aws::SSM::Client.new
    end

    def fetch(key, *args, &block)
      key = key.to_s
      self.cache ||= {}
      unless cache.key?(key)
        # cache params to minimize number of requests
        cache[key] = adapter_instance.fetch(key, *args, &block)
      end
      cache[key]
    end

    def copy_to_env(*keys)
      keys.flatten.map!(&:to_s)
      adapter_instance.fetch_all(*keys).each do |key, value|
        ENV[key] = value
      end
    end

    def adapter=(adapter)
      @adapter = adapter
      # erase previous instance and cache
      self.adapter_instance = nil
      self.cache = {}
    end

    private

    def adapter_instance
      @adapter_instance ||= initialize_adapter
    end

    def initialize_adapter
      case adapter
      when :env
        Adapters::Env.new
      when :aws_ssm
        Adapters::SSM.new
      else
        raise "Invalid adapter: #{adapter}"
      end
    end
  end
end