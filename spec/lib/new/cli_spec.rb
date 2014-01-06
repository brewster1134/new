require 'spec_helper'

describe New::Cli do
  describe '#templates' do
    before do
      New.stub(:templates).and_return([:foo])
      subject.stub(:template)
    end

    after do
      New.unstub(:templates)
      subject.unstub(:template)
    end

    it 'should accept template name as argument' do
      expect { subject.foo 'party' }.to_not raise_error
    end

    it 'should raise an error if no name is given' do
      expect { subject.foo }.to raise_error
    end

    it 'should raise an error for non-template argument' do
      expect { subject.bar }.to raise_error
    end
  end

  describe '#init' do
    before do
      stub_const 'New::Template::CUSTOM_FOLDER', root('.tmp', '.new')
      stub_const 'New::Template::CUSTOM_TEMPLATES', root('.tmp', '.new', 'templates')
      stub_const 'New::Template::CUSTOM_CONFIG_FILE', root('.tmp', '.new', '.new')
      subject.init
    end

    after :all do
      FileUtils.rm_r root('.tmp', '.new')
    end

    it 'should create .new dir' do
      expect(Dir.exists?(root('.tmp', '.new')))
    end

    it 'should create .new file' do
      expect(File.exists?(root('.tmp', '.new', '.new')))
    end

    it 'should create an empty templates dir' do
      expect(Dir.exists?(root('.tmp', '.new', 'templates')))
    end
  end
end
