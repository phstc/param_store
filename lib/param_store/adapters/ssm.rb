module ParamStore
  module Adapters
    class SSM
      def fetch(key, *args, **opts, &block)
        tmp = {}
        key = prepend_path(opts[:path], key)
        begin
          tmp[key] = ParamStore.ssm_client.get_parameter(name: key, with_decryption: true).parameter.value
        rescue Aws::SSM::Errors::ParameterNotFound
          # let the tmp.fetch below deal with not found key and defaults
        end
        tmp.fetch(key, *args, &block)
      end

      def fetch_all(*keys, **opts)
        path = opts[:path]
        keys = keys.flatten
        keys = keys.map { |key| prepend_path(path, key) } if path
        ParamStore.ssm_client.get_parameters(names: keys, with_decryption: true).parameters.each_with_object({}) do |param, result|
          result[param.name.gsub(path.to_s, '')] = param.value
        end
      end

      private

      def prepend_path(path, key)
        return key unless path

        "#{path}#{key}"
      end
    end
  end
end