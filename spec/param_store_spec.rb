RSpec.describe ParamStore do
  describe '.fetch' do
    context 'when :env' do
      before { ParamStore.adapter = :env }

      it 'retrieves a value' do
        expect_any_instance_of(ParamStore::Adapters::Env).to receive(
          :fetch
        ).once.with(
          'key1'
        ).and_return('value')
        expect(subject.fetch('key1')).to eq('value')
      end
    end

    context 'when :aws_ssm' do
      let(:ssm_client) { double 'SSM client' }

      before do
        ParamStore.adapter = :aws_ssm
        allow(subject).to receive(:ssm_client).and_return(ssm_client)
      end

      it 'caches retuned values' do
        expect_any_instance_of(ParamStore::Adapters::SSM).to receive(
          :fetch
        ).once.with(
          'key1a'
        ).and_return('value')

        expect(subject.fetch('key1a')).to eq('value')
        expect(subject.fetch('key1a')).to eq('value')
      end
    end

    context 'when invalid adapter' do
      specify do
        ParamStore.adapter = nil
        expect { subject.fetch('key1yy') }.to raise_error('Invalid adapter: ')
      end
    end
  end

  describe '.copy_to_env' do
    specify do
      ParamStore.adapter = :aws_ssm
      allow_any_instance_of(ParamStore::Adapters::SSM).to receive(
        :fetch_all
      ).with(
        'key1', 'key2'
      ).and_return('key1' => 'value1', 'key2' => 'value2')

      subject.copy_to_env('key1', 'key2')

      expect(ENV['key1']).to eq('value1')
      expect(ENV['key2']).to eq('value2')
    end
  end

  describe '.require!' do
    it 'does not raise an error' do
      ParamStore.adapter = :aws_ssm
      allow_any_instance_of(ParamStore::Adapters::SSM).to receive(
        :fetch_all
      ).with(
        'key1', 'key2'
      ).and_return('key1' => 'value1', 'key2' => 'value2')

      expect { subject.require!('key1', 'key2') }.to_not raise_error
    end

    context 'whe missing' do
      it 'does not raise an error' do
        ParamStore.adapter = :aws_ssm
        allow_any_instance_of(ParamStore::Adapters::SSM).to receive(
          :fetch_all
        ).with(
          'key1', 'key2', 'key3'
        ).and_return('key1' => 'value1', 'key2' => 'value2')

        expect { subject.require!('key1', 'key2', 'key3') }.to raise_error('Missing keys: key3')
      end
    end
  end
end
