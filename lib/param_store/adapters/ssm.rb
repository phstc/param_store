module ParamStore
  module Adapters
    class SSM
      def fetch(key, *args, &block)
        tmp = {}
        tmp[key] = ParamStore.ssm_client.get_parameter(name: key, with_decryption: true).value
      rescue Aws::SSM::Errors::ParameterNotFound
        # let the ensure below (tmp.fetch) deal with not found key and defaults
      ensure
        return tmp.fetch(key, *args, &block)
      end
    end
  end
end