require 'spec_helper'

RSpec.describe ParamStore::Adapters::SSM do
  let(:ssm_client) { double 'SSM client' }

  before do
    ParamStore.adapter :aws_ssm
    allow(ParamStore).to receive(:ssm_client).and_return(ssm_client)
  end

  describe '#fetch' do
    it 'retrieves a value' do
      allow(ssm_client).to receive(
        :get_parameter
      ).with(
        name: 'key1',
        with_decryption: true
      ).and_return(double(parameter: double(value: 'value')))
      expect(subject.fetch('key1')).to eq('value')
    end

    it 'retrieves with a path' do
      allow(ssm_client).to receive(
        :get_parameter
      ).with(
        name: '/Dev/App/key1a',
        with_decryption: true
      ).and_return(double(parameter: double(value: 'value')))

      expect(subject.fetch('key1a', path: '/Dev/App/')).to eq('value')
    end

    it 'retrieves with a default path' do
      allow(ssm_client).to receive(
        :get_parameter
      ).with(
        name: '/Prod/App/key1a',
        with_decryption: true
      ).and_return(double(parameter: double(value: 'value')))

      subject = described_class.new(default_path: '/Prod/App/')
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

  describe '#fetch_all' do
    specify do
      allow(ssm_client).to receive(
        :get_parameters
      ).with(
        names: %w[/Dev/App/key1 /Dev/App/key2],
        with_decryption: true
      ).and_return(
        double(
          parameters: [
            double(name: 'key1', value: 'value1'),
            double(name: 'key2', value: 'value2')
          ]
        )
      )

      expect(subject.fetch_all(%w[key1 key2], path: '/Dev/App/')).to eq('key1' => 'value1', 'key2' => 'value2')
    end

    it 'ignores not found keys' do
      allow(ParamStore.ssm_client).to receive(
        :get_parameters
      ).and_return(
        double(
          parameters: [
          ]
        )
      )
      expect(subject.fetch_all('not_found', 'keys2')).to eq({})
    end
  end
end