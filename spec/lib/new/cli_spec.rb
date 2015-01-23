describe New::Cli do
  before do
    # run all cli commands from the project fixture directory
    @pwd = FileUtils.pwd
    FileUtils.chdir root('spec', 'fixtures', 'project')

    # initialize cli instance
    @cli = New::Cli.new
  end

  after do
    # change back to root for the rest of the tests
    FileUtils.chdir @pwd
  end

  describe '#init' do
    before do
      # set the home directory to tmp
      stub_const 'New::HOME_DIRECTORY', root('tmp')

      FileUtils.rm_rf File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)
    end

    context 'when home Newfile doesnt exist' do
      before do
        @cli.init
      end

      it 'should create a default Newfile' do
        newfile_object = YAML.load(File.read(File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME)))
        expect(newfile_object['sources']['default']).to eq 'brewster1134/new-tasks'
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
      allow(New).to receive(:load_newfiles)
      allow(New::Source).to receive(:load_sources)
      allow(New::Source).to receive(:sources).and_return({
        :source_name => OpenStruct.new({ :path => '/source', :tasks => { :task_name => 'task' }}),
      })

      @cli.tasks
    end

    after do
      allow(New).to receive(:load_newfiles).and_call_original
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
      expect(S).to have_received(:ay).with(including('source_name#task_name'), anything).ordered
    end
  end

  describe.skip '#release' do
    before do
      allow(New).to receive(:new)
    end

    before do
      allow(New).to receive(:new).and_call_original
    end

    it 'should initialize' do
      @cli.release

      expect(New).to have_received(:new)
    end
  end

  describe.skip '#version' do
    it 'should return the current version' do
      expect{ @cli.tasks }.to output('1.2.3').to_stdout
    end
  end
end
