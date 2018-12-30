module ParamStore
  module Adapters
    class Env
      def initialize(**_opts); end

      def fetch(key, *args, **_opts, &block)
        ENV.fetch(key, *args, &block)
      end

      def fetch_all(*keys, **_opts)
        keys = keys.flatten
        keys.each_with_object({}) do |key, result|
          result[key] = ENV[key]
        end
      end
    end
  end
end