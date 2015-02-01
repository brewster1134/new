describe New do
  describe '.load_newfiles' do
    before do
      allow(New).to receive(:load_newfile)

      New.load_newfiles
    end

    after do
      allow(New).to receive(:load_newfile).and_call_original
    end

    it 'should load home Newfile' do
      expect(New).to have_received(:load_newfile).with(File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME))
    end

    it 'should load project Newfile' do
      expect(New).to have_received(:load_newfile).with(File.join(Dir.pwd, New::NEWFILE_NAME))
    end
  end

  describe '.load_newfile' do
    before do
      allow(New).to receive(:new_object=)

      New.send :load_newfile, root('spec', 'fixtures', New::NEWFILE_NAME)
    end

    after do
      allow(New).to receive(:new_object=).and_call_original
    end

    it 'should load yaml Newfile as ruby hash' do
      expect(New).to have_received(:new_object=).with hash_including({ 'sources' => hash_including({ 'home_local' => '/home_local/source' })})
    end
  end

  describe '.new_object=' do
    before do
      New.class_var :new_object, {
        :foo => {
          :bar => 'baz'
        }
      }

      New.send :new_object=, {
        'foo' => {
          'bar' => 'foobar'
        }
      }
    end

    it 'should merge data into a symbolized hash' do
      expect(New.class_var(:new_object)).to eq({
        :foo => {
          :bar => 'foobar'
        }
      })
    end
  end

  describe '#initialize' do
    before do
      class FooTask
        def initialize options; end
      end
      class BarTask
        def initialize options; end
      end
      allow(FooTask).to receive(:new)
      allow(BarTask).to receive(:new)
      allow(New).to receive(:load_newfiles)
      allow(New::Source).to receive(:load_sources)
      allow(New::Source).to receive(:find_task_path)
      allow(New::Task).to receive(:load)

      New.class_var :new_object, {
        :other => :option,
        :tasks => {
          :foo_task => {
            :foo_option => true
          },
          :bar_task => {
            :source => :bar_source,
            :bar_option => true
          }
        }
      }

      New::Task.class_var :tasks, {
        :foo_task => FooTask,
        :bar_task => BarTask
      }
    end

    after do
      allow(New).to receive(:load_newfiles).and_call_original
      allow(New::Source).to receive(:load_sources).and_call_original
      allow(New::Source).to receive(:find_task_path).and_call_original
      allow(New::Task).to receive(:load).and_call_original
    end

    context 'when initialized' do
      before do
        New.new '1.2.3'
      end

      it 'should search for tasks' do
        expect(New::Source).to have_received(:find_task_path).with(:foo_task, nil).ordered
        expect(New::Source).to have_received(:find_task_path).with(:bar_task, :bar_source).ordered
      end

      it 'should load tasks' do
        expect(New::Task).to have_received(:load).twice
      end

      it 'should run tasks' do
        expect(FooTask).to have_received(:new).with({ :other => :option, :foo_option => true })
        expect(BarTask).to have_received(:new).with({ :other => :option, :bar_option => true })
      end
    end

    context 'when initialized via cli' do
      before do
        New.class_var :cli, true
        New.new '1.2.3'
      end

      it 'should not load Newfiles' do
        expect(New).to_not have_received(:load_newfiles)
      end
    end

    context 'when initialized via ruby' do
      before do
        New.class_var :cli, false
        New.new '1.2.3'
      end

      it 'should load Newfiles' do
        expect(New).to have_received(:load_newfiles)
      end
    end
  end
end
