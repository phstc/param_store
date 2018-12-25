require 'spec_helper'

RSpec.describe ParamStore::Adapters::Env do
  describe '#fetch' do
    it 'retrieves a value' do
      ENV['key1'] = 'value'
      expect(subject.fetch(:key1)).to eq('value')
    end

    context 'when not found' do
      it 'raises an error' do
        expect { subject.fetch(:not_found) }.to raise_error(KeyError)
      end

      it 'uses default value' do
        expect(subject.fetch(:not_found, 'value')).to eq('value')
      end

      it 'uses block value' do
        expect(subject.fetch(:not_found) { 'value' }).to eq('value')
      end
    end
  end
end