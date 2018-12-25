module ParamStore
  module Adapters
    class Env
      def fetch(key)
        ENV[key.to_s]
      end
    end
  end
end