describe New::Cli do
  before do
    allow(New).to receive(:load_newfiles)

    # run all cli commands from the project fixture directory
    @pwd = FileUtils.pwd
    FileUtils.chdir root('spec', 'fixtures', 'project')

    # initialize cli instance
    @cli = New::Cli.new
  end

  after do
    allow(New).to receive(:load_newfiles).and_call_original

    # change back to root for the rest of the tests
    FileUtils.chdir @pwd
  end

  describe '#init' do
    before do
      FileUtils.rm_rf File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)
    end

    context 'when home Newfile doesnt exist' do
      before do
        @cli.init
      end

      it 'should create a default Newfile' do
        newfile_object = YAML.load(File.read(File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)))
        expect(newfile_object['sources']['default']).to be_a String
      end
    end

    context 'when home Newfile already exists' do
      before do
        allow(File).to receive(:open).and_call_original

        # call twice... once to create the file, and again to test when it already exists
        @cli.init
        @cli.init
      end

      it 'should not attempt to create a Newfile' do
        expect(File).to have_received(:open).once
        expect(S).to have_received(:ay).twice
      end
    end
  end

  describe '#tasks' do
    before do
      allow(New::Source).to receive(:load_sources)
      allow(New::Source).to receive(:sources).and_return({
        :source_name => OpenStruct.new({ :path => '/source', :tasks => { :task_name => 'task' }}),
      })

      @cli.tasks
    end

    after do
      allow(New::Source).to receive(:load_sources).and_call_original
      allow(New::Source).to receive(:sources).and_call_original
    end

    it 'should request to load newfiles and sources' do
      expect(New).to have_received(:load_newfiles).ordered
      expect(New::Source).to have_received(:load_sources).ordered
    end

    it 'should list all available tasks' do
      expect(S).to have_received(:ay).with('source_name', anything).ordered
      expect(S).to have_received(:ay).with(including('/source'), anything).ordered
      expect(S).to have_received(:ay).with('task_name', anything).ordered
    end
  end

  describe '#release' do
    before do
      allow(New).to receive(:new)

      New.new_object = {
        :version => '1.2.3'
      }
    end

    after do
      allow(New).to receive(:new).and_call_original
    end

    context 'when bumping any version' do
      before do
        allow(A).to receive(:sk).and_yield 'p'
        @cli.release
      end

      it 'should set the cli flag' do
        expect(New.cli).to eq true
      end

      it 'should load Newfiles and sources once' do
        expect(New).to have_received(:load_newfiles).once
      end

      it 'should initialize' do
        expect(New).to have_received(:new).with '1.2.4'
      end
    end

    context 'when bumping a patch version' do
      before do
        allow(A).to receive(:sk).and_yield 'p'
        @cli.release
      end

      it 'should increment the patch version' do
        expect(New).to have_received(:new).with '1.2.4'
      end
    end

    context 'when bumping a minor version' do
      before do
        allow(A).to receive(:sk).and_yield 'm'
        @cli.release
      end

      it 'should increment the minor version and set the patch version to 0' do
        expect(New).to have_received(:new).with '1.3.0'
      end
    end

    context 'when bumping a major version' do
      before do
        allow(A).to receive(:sk).and_yield 'M'
        @cli.release
      end

      it 'should increment the major version and set the minor & patch versions to 0' do
        expect(New).to have_received(:new).with '2.0.0'
      end
    end
  end

  describe '#version' do
    before do
      New.class_var :new_object, {
        :name => 'Project Name',
        :version => '1.2.3'
      }
    end

    it 'should return the current version' do
      @cli.version

      expect(S).to have_received(:ay).with 'Project Name', anything
      expect(S).to have_received(:ay).with '1.2.3', anything
    end
  end
end
