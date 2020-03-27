require 'spec_helper'

RSpec.describe ParamStore::Adapters::SecretsManager do
  let(:secrets_manager_client) { double 'Secrets Manager client' }

  before do
    ParamStore.adapter :aws_secrets_manager
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

    context 'when secret_id' do
      it 'retrieves specific keys and cache lookups' do
        expect(secrets_manager_client).to receive(
          :get_secret_value
        ).once.with(
          secret_id: 'keys',
          version_id: nil,
          version_stage: nil
        ).and_return(double(secret_string: '{"key1":"value1", "key2":"value2"}'))

        expect(subject.fetch('key1', secret_id: 'keys')).to eq('value1')
        expect(subject.fetch('key2', secret_id: 'keys')).to eq('value2')
      end
    end

    context 'when a default secret_id' do
      it 'retrieves specific keys and cache lookups' do
        expect(secrets_manager_client).to receive(
          :get_secret_value
        ).once.with(
          secret_id: 'keys',
          version_id: nil,
          version_stage: nil
        ).and_return(double(secret_string: '{"key1":"value1", "key2":"value2"}'))

        subject = described_class.new(default_secret_id: 'keys')

        expect(subject.fetch('key1')).to eq('value1')
        expect(subject.fetch('key2')).to eq('value2')
      end
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

  describe '#featch_all' do
    specify do
      allow(secrets_manager_client).to receive(
        :get_secret_value
      ).with(
        secret_id: 'keys1',
        version_id: nil,
        version_stage: nil
      ).and_return(double(secret_string: '{"keys1_key1":"value"}'))

      allow(secrets_manager_client).to receive(
        :get_secret_value
      ).with(
        secret_id: 'keys2',
        version_id: nil,
        version_stage: nil
      ).and_return(double(secret_string: '{"keys2_key1":"value"}'))

      expect(subject.fetch_all('keys1', 'keys2')).to eq(
        'keys1' => { 'keys1_key1' => 'value' },
        'keys2' => { 'keys2_key1' => 'value' }
      )
    end

    it 'ignores not found keys' do
      allow(ParamStore.secrets_manager_client).to receive(
        :get_secret_value
      ).and_raise(
        Aws::SecretsManager::Errors::ResourceNotFoundException.new({}, 'not found')
      )
      expect(subject.fetch_all('not_found')).to eq({})
    end
  end
end