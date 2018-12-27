module ParamStore
  class Wrapper
    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def fetch(key, *args, **opts, &block)
      key = key.to_s
      unless cache.key?(key)
        # cache params to minimize number of requests
        cache[key] = adapter_instance.fetch(key, *args, **opts, &block)
      end
      cache[key]
    end

    def copy_to_env(*keys, **opts)
      cache_all(*keys, **opts)

      require_keys!(*keys, **opts) if opts[:require_keys]

      keys.each { |key| ENV[key] = cache[key] }
    end

    def require_keys!(*keys, **opts)
      cache_all(*keys, **opts)

      missing = keys.flatten.map!(&:to_s) - cache.keys

      return if missing.none?

      raise "Missing keys: #{missing.join(', ')}"
    end

    private

    attr_accessor :adapter, :cache

    def cache_all(*keys, **opts)
      keys.flatten.map!(&:to_s)
      adapter_instance.fetch_all(*keys, **opts).each do |key, value|
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