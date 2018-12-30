module ParamStore
  module Adapters
    class SSM
      attr_reader :default_path

      def initialize(default_path: nil)
        @default_path = default_path
      end

      def fetch(key, *args, path: nil, &block)
        tmp = {}
        key = prepend_path(path, key)
        begin
          tmp[key] = ParamStore.ssm_client.get_parameter(name: key, with_decryption: true).parameter.value
        rescue Aws::SSM::Errors::ParameterNotFound
          # let the tmp.fetch below deal with not found key and defaults
        end
        tmp.fetch(key, *args, &block)
      end

      def fetch_all(*keys, path: nil)
        keys = keys.flatten
        keys = keys.map { |key| prepend_path(path, key) } if path
        ParamStore.ssm_client.get_parameters(names: keys, with_decryption: true).parameters.each_with_object({}) do |param, result|
          result[param.name.gsub(path.to_s, '')] = param.value
        end
      end

      private

      def prepend_path(path, key)
        "#{path || default_path}#{key}"
      end
    end
  end
end