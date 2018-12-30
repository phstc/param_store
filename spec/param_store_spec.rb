RSpec.describe ParamStore do
  describe '.adapter' do
    it 'initializes wrapper' do
      subject.adapter :aws_ssm
      expect(subject.wrapper).to be
    end

    it 'raises error' do
      expect { subject.adapter :lol }.to raise_error('Invalid adapter: lol')
    end
  end
end
