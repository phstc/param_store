module ParamStore
  module Adapters
    class SecretsManager
      def initialize(**_opts); end

      def fetch(key, *args, version_id: nil, version_stage: nil, &block)
        tmp = {}
        if string = get_secret_value(key, version_id, version_stage)
          tmp[key] = JSON.parse(string)
        end
        tmp.fetch(key, *args, &block)
      end

      def fetch_all(*keys, **opts); end

      private

      def get_secret_value(key, version_id, version_stage)
        options = { secret_id: key }
        options[:version_id] = version_id
        options[:version_stage] = version_stage
        ParamStore.secrets_manager_client.get_secret_value(options).secret_string
      rescue Aws::SecretsManager::Errors::ResourceNotFoundException
        # let the tmp.fetch below deal with key not found and defaults
      end

      def prepend_path(path, key)
        "#{path || default_path}#{key}"
      end
    end
  end
end