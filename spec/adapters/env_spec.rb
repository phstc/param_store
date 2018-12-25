require 'spec_helper'

RSpec.describe ParamStore::Adapters::Env do
  describe '#fetch' do
    it 'retrieves a value' do
      ENV['key1'] = 'value'
      expect(subject.fetch(:key1)).to eq('value')
    end
  end
end