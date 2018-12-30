require 'spec_helper'

RSpec.describe ParamStore::Adapters::SecretsManager do
  let(:secrets_manager_client) { double 'Secrets Manager client' }

  before do
    allow(ParamStore).to receive(:secrets_manager_client).and_return(secrets_manager_client)
  end

  describe '#fetch' do
    it 'retrieves a value' do
      allow(secrets_manager_client).to receive(
        :get_secret_value
      ).with(
        secret_id: 'keys',
        version_id: nil,
        version_stage: nil
      ).and_return(double(secret_string: '{"key1":"value"}'))

      expect(subject.fetch('keys')).to eq('key1' => 'value')
    end

    context 'when not found' do
      before do
        allow(ParamStore.secrets_manager_client).to receive(
          :get_secret_value
        ).and_raise(
          Aws::SecretsManager::Errors::ResourceNotFoundException.new({}, 'not found')
        )
      end

      it 'raises an error' do
        expect { subject.fetch('not_found') }.to raise_error(KeyError)
      end

      it 'uses default value' do
        expect(subject.fetch('not_found', 'value')).to eq('value')
      end

      it 'uses block value' do
        expect(subject.fetch('not_found') { 'value' }).to eq('value')
      end
    end
  end
end