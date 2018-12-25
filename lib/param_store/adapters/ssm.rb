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

      def fetch_all(*keys)
        keys = keys.flatten
        keys = keys.map { |key| "#{ParamStore.path}/#{key}" } unless ParamStore.path.nil?
        ParamStore.ssm_client.get_parameters(names: keys, with_decryption: true).parameters.each_with_object({}) do |param, result|
          result[param.name.gsub(ParamStore.path.to_s, '')] = param.value
        end
      end
    end
  end
end