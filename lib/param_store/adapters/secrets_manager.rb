module ParamStore
  module Adapters
    class SecretsManager
      attr_reader :default_secret_id

      def initialize(default_secret_id: nil)
        @default_secret_id = default_secret_id
      end

      def fetch(key, *args, secret_id: nil, version_id: nil, version_stage: nil, &block)
        get_key = secret_id || default_secret_id || key

        if cache[get_key].nil? &&
           string = get_secret_value(get_key, version_id, version_stage)
          cache[get_key] = JSON.parse(string)
        end

        (
          secret_id.nil? && default_secret_id.nil? ? cache : cache[get_key]
        ).fetch(key, *args, &block)
      end

      def fetch_all(*keys, **opts)
        # poor man's fetch all
        # I couldn't find a batch get for secrets manager :/
        keys.map { |key| fetch(key, {}, **opts) }.inject(:merge)
      end

      private

      def get_secret_value(secret_id, version_id, version_stage)
        ParamStore.secrets_manager_client.get_secret_value(
          secret_id: secret_id,
          version_id: version_id,
          version_stage: version_stage
        ).secret_string
      rescue Aws::SecretsManager::Errors::ResourceNotFoundException
        # let the tmp.fetch below deal with key not found and defaults
      end

      def cache
        @_cache ||= {}
      end
    end
  end
end