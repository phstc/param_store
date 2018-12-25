require 'spec_helper'

RSpec.describe ParamStore::Adapters::SSM do
  let(:ssm_client) { double 'SSM client' }

  before do
    allow(ParamStore).to receive(:ssm_client).and_return(ssm_client)
  end

  describe '#fetch' do
    it 'retrieves a value' do
      allow(ssm_client).to receive(
        :get_parameter
      ).with(
        name: 'key1',
        with_decryption: true
      ).and_return(double(value: 'value'))
      expect(subject.fetch('key1')).to eq('value')
    end

    it 'retrieves with default path' do
      ParamStore.path = '/Dev/App'

      allow(ssm_client).to receive(
        :get_parameter
      ).with(
        name: '/Dev/App/key1a',
        with_decryption: true
      ).and_return(double(value: 'value'))
      expect(subject.fetch('key1a')).to eq('value')
    end

    context 'when not found' do
      before do
        allow(ParamStore.ssm_client).to receive(
          :get_parameter
        ).and_raise(
          Aws::SSM::Errors::ParameterNotFound.new({}, 'not found')
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