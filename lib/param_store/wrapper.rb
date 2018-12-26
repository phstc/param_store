module ParamStore
  class Wrapper
    def initialize(adapter_class)
      @adapter_class = adapter_class
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

    def require!(*keys)
      cache_all(*keys)

      missing = keys.flatten.map!(&:to_s) - cache.keys

      return if missing.none?

      raise "Missing keys: #{missing.join(', ')}"
    end

    private

    attr_accessor :adapter, :cache

    def cache_all(*keys)
      keys.flatten.map!(&:to_s)
      adapter_instance.fetch_all(*keys).each do |key, value|
        cache[key] = value
      end
    end

    def cache
      @_cache ||= {}
    end

    def adapter_instance
      @_adapter_instance ||= @adapter_class.new
    end
  end
end