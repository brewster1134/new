require 'active_support/core_ext/hash/keys'

describe New::Cli do
  before do
    allow(New).to receive(:new)

    # run all cli commands from the project fixture directory
    @pwd = FileUtils.pwd
    FileUtils.chdir root('spec', 'fixtures', 'project')

    # set the home directory to tmp
    stub_const 'New::HOME_DIRECTORY', root('tmp')

    # initialize cli instance
    @cli = New::Cli.new
  end

  after do
    allow(New).to receive(:new).and_call_original

    # change back to root for the rest of the tests
    FileUtils.chdir @pwd
  end

  describe '#init' do
    it 'should create a default Newfile' do
      @cli.init
      newfile_object = YAML.load(File.read(File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME))).symbolize_keys

      expect(newfile_object[:tasks]).to be_a Hash
    end
  end

  describe '#tasks' do
    it 'should list all available tasks' do
      expect{ @cli.tasks }.to output(/local_task/, /remote_task/).to_stdout
    end
  end

  describe '#release' do
    it 'should initialize' do
      @cli.release

      expect(New).to have_received(:new)
    end
  end

  describe '#version' do
    it 'should return the current version' do
      expect{ @cli.tasks }.to output('1.2.3').to_stdout
    end
  end
end
