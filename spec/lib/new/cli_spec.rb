require 'spec_helper'

describe New::Cli do
  context 'with templates' do
    before do
      subject.stub(:template)
    end

    after do
      subject.unstub(:template)
    end

    it 'should accept template name as argument' do
      expect { subject.js '--name', 'party' }.to_not raise_error
    end

    it 'should raise an error for non-template argument' do
      expect { subject.foo }.to raise_error
    end
  end
end
