require 'spec_helper'

RSpec.describe ParamStore::Adapters::EJSONWrapper do
  let(:file_path) { 'myfile.ejson' }
  let(:result) do
    {
      'key1' => 'value1',
      'key2' => 'value2'
    }
  end

  subject { described_class.new(file_path: file_path) }

  before do
    allow(::EJSONWrapper).to receive(:decrypt).with(file_path, {}).and_return(result)
  end

  describe '#fetch' do
    it 'retrieves a value' do
      expect(subject.fetch('key1')).to eq('value1')
    end

    context 'when not found' do
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
      expect(subject.fetch_all(%w[key1 key2])).to eq('key1' => 'value1', 'key2' => 'value2')
    end
  end
end