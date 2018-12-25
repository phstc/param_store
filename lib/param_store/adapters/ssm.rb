module ParamStore
  module Adapters
    class SSM
      def fetch(key, *args, &block)
        tmp = {}
        key = "#{ParamStore.path}/#{key}" unless ParamStore.path.nil?
        begin
          tmp[key] = ParamStore.ssm_client.get_parameter(name: key, with_decryption: true).parameter.value
        rescue Aws::SSM::Errors::ParameterNotFound
          # let the tmp.fetch below deal with not found key and defaults
        end
        tmp.fetch(key, *args, &block)
      end
    end
  end
end