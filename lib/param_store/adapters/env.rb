module ParamStore
  module Adapters
    class Env
      def fetch(key, *args, &block)
        ENV.fetch(key.to_s, *args, &block)
      end
    end
  end
end