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
      stub_const 'New::CUSTOM_DIR', root('.tmp', '.new')
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

    it 'should create an empty templates & tasks dir' do
      expect(Dir.exists?(root('.tmp', '.new', 'templates')))
      expect(Dir.exists?(root('.tmp', '.new', 'tasks')))
    end
  end

  describe '#release' do
    context 'for an invalid project' do
      before do
        Dir.chdir root('.tmp')
        File.delete '.new' rescue nil
      end

      it 'should raise an error if no config file is found' do
        expect { subject.release }.to raise_error
      end
    end

    context 'for a valid project' do
      before do
        Dir.chdir root('spec', 'fixtures', 'project')
        New::Task.stub(:new)
        subject.release
      end

      after do
        New::Task.unstub(:new)
      end

      it 'should run the project task methods' do
        expect(New::Task).to have_received(:new).with(:foo_task, {:tasks=>[:foo_task]})
      end
    end
  end
end
