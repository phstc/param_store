require 'aws-sdk-ssm'

require 'param_store/version'
require 'param_store/adapters/env'
require 'param_store/adapters/ssm'

module ParamStore
  class << self
    attr_accessor :path
    attr_writer :adapter_instance, :cache
    attr_reader :adapter

    def ssm_client
      @_ssm_client ||= Aws::SSM::Client.new
    end

    def fetch(key, *args, &block)
      key = key.to_s
      unless cache.key?(key)
        # cache params to minimize number of requests
        cache[key] = adapter_instance.fetch(key, *args, &block)
      end
      cache[key]
    end

    def copy_to_env(*keys)
      cache_all(*keys)
      keys.each { |key| ENV[key] = cache[key] }
    end

    def adapter=(adapter)
      @adapter = adapter
      # erase previous instance and cache
      self.adapter_instance = nil
      self.cache = {}
    end

    def require!(*keys)
      cache_all(*keys)

      missing = keys.flatten.map!(&:to_s) - cache.keys

      return if missing.none?

      raise "Missing keys: #{missing.join(', ')}"
    end

    private

    def cache_all(*keys)
      keys.flatten.map!(&:to_s)
      adapter_instance.fetch_all(*keys).each do |key, value|
        cache[key] = value
      end
    end

    def cache
      @cache ||= {}
    end

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