require 'spec_helper'

describe New::Cli do
  before do
    @cli = New::Cli.new
  end

  describe '#templates' do
    it 'should list available templates' do
      expect(@cli.templates).to match_array [:foo_template]
    end
  end

  describe '#init' do
    before do
      @tmp_dir = Dir.mktmpdir
      stub_const 'New::GLOBAL_CONFIG_FILE', File.join(@tmp_dir, New::CONFIG_FILE)

      @cli.init
    end

    it 'should create a .new configuration file' do
      expect(File.exists(New::GLOBAL_CONFIG_FILE)).to be true
    end
  end

  describe '#project' do
    before do
      @pwd = Dir.pwd
      @tmp_dir = Dir.mktmpdir

      Dir.chdir @tmp_dir

      @cli.project 'foo_template', 'foo_project'
    end

    after do
      Dir.chdir @pwd
    end

    it 'should create a new directory for the project' do
      expect(File.exists(File.join(@tmp_dir, New::CONFIG_FILE))).to be true
    end

    it 'should create interpolated assets' do
      expect(File.exists(File.join(@tmp_dir, 'baz.txt'))).to be true
      expect(File.read(File.join(@tmp_dir, 'baz.txt'))).to include 'foo baz'
    end
  end

  describe '#release' do
    before do
      require 'spec/fixtures/foo_task/foo_task'
      allow(New::FooTask).to receive(:run)

      @pwd = Dir.pwd
      Dir.chdir root('spec', 'fixtures', 'foo_project')
      @cli.release
    end

    after do
      allow(New::FooTask).to receive(:run).and_call_original
      Dir.chdir @pwd
    end

    it 'should call run for the listed tasks' do
      expect(New::FooTask).to receive(:run)
    end
  end

  describe '#version' do
    before do
      @pwd = Dir.pwd
      Dir.chdir root('spec', 'fixtures', 'foo_project')
    end


    it 'should return the current version of the new gem' do
      expect(@cli.version.to_s).to eq '1.2.3'
    end
  end
end
