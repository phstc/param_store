module ParamStore
  module Adapters
    class SSM
      def fetch(key, *args, &block)
        tmp = {}
        begin
          tmp[key] = ParamStore.ssm_client.get_parameter(name: key, with_decryption: true).value
        rescue Aws::SSM::Errors::ParameterNotFound
          # let the tmp.fetch below deal with not found key and defaults
        end
        tmp.fetch(key, *args, &block)
      end
    end
  end
end