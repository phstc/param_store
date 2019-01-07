require 'spec_helper'

RSpec.describe ParamStore::Adapters::Env do
  before do
    ParamStore.adapter :env
  end

  describe '#fetch' do
    it 'retrieves a value' do
      stub_env('key1', 'value')
      expect(subject.fetch('key1')).to eq('value')
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
      stub_env('key1', 'value1')
      stub_env('key2', 'value2')
      expect(subject.fetch_all(%w[key1 key2])).to eq('key1' => 'value1', 'key2' => 'value2')
    end
  end
end