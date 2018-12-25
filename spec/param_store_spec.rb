RSpec.describe ParamStore do
  describe '.fetch' do
    context 'when :env' do
      before { ParamStore.adapter = :env }

      it 'retrieves a value' do
        stub_env('key1', 'value')
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
        allow(ssm_client).to receive(
          :get_parameter
        ).once.with(
          name: 'key1a', with_decryption: true
        ).and_return(double(parameter: double(value: 'value')))

        expect(subject.fetch('key1a')).to eq('value')
        expect(subject.fetch('key1a')).to eq('value')
      end
    end

    context 'when invalid adapter' do
      before do
        ParamStore.adapter = nil
      end

      specify do
        expect { subject.fetch('key1yy') }.to raise_error('Invalid adapter: ')
      end
    end
  end
end
