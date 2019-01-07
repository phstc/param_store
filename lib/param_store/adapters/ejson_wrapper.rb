module ParamStore
  module Adapters
    class EJSONWrapper
      attr_reader :file_path, :options

      def initialize(**opts)
        @file_path = opts.delete(:file_path)
        @options = opts
      end

      def fetch(key, *args, **_opts, &block)
        decrypt.fetch(key, *args, &block)
      end

      def fetch_all(*keys, **_opts)
        decrypt.select { |key, _value| keys.flatten.include?(key) }
      end

      private

      def decrypt
        @_decrypt ||= ::EJSONWrapper.decrypt(file_path, options)
      end
    end
  end
end