module ParamStore
  module Adapters
    class Env
      def fetch(key, *args, &block)
        ENV.fetch(key, *args, &block)
      end

      def fetch_all(*keys)
        keys = keys.flatten
        keys.each_with_object({}) do |key, result|
          result[key] = ENV[key]
        end
      end
    end
  end
end