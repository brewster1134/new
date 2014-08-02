require 'spec_helper'
require_task :gem

describe New::Task::Gem do
  before do
    stub_const 'New::CONFIG_FILE', New::CONFIG_FILE
    stub_const 'New::Task::Gem::GLOB_ATTRIBUTES', [:foo_files]
    @gem = new_task :gem, { version: '1.2.3' }
    @pwd = Dir.pwd
    @tmp_dir = Dir.mktmpdir

    Dir.chdir @tmp_dir
  end

  after do
    Dir.chdir @pwd
  end

  describe '#set_version' do
    before do
      @gem.send(:set_version)
    end

    it 'should set the version for project options' do
      expect(@gem.project_options[:version]).to eq '1.2.4'
    end
  end

  describe '#validate_files' do
    before do
      # temporarily change the current directory to the gem task folder to test for valid files
      Dir.chdir File.dirname(__FILE__)

      @gem.instance_variable_set(:@gemspec, { foo_files: ['*.rb', '*.md'] })
      @gem.send(:validate_files)
    end

    after do
      # go back to the original root dir
      Dir.chdir @tmp_dir
    end

    it 'should replace the file_attr array of globs with an array of files' do
      files = @gem.instance_variable_get(:@gemspec)[:foo_files]
      expect(files.all?{ |f| files.include? f }).to eq true
    end
  end

  describe '#render_gemspec_options' do
    before do
      allow(@gem).to receive(:extract_gem_dependencies).and_return(['  s.extract_gem_dependencies'])
      @gem.instance_variable_set(:@gemspec, {})
      @gem.send(:render_gemspec_options)
    end

    after do
      allow(@gem).to receive(:extract_gem_dependencies).and_call_original
    end

    it 'should create the gemspec_string option' do
      gemspec_string = @gem.project_options[:gemspec_string]
      expect(gemspec_string).to include "s.author = 'Foo Bar'"
      expect(gemspec_string).to include "s.license = 'MIT'"
      expect(gemspec_string).to include "s.extract_gem_dependencies"
    end

    context 'when plurals are set' do
      before do
        @gem.instance_variable_set(:@gemspec, {
          authors: ['Foo Author'],
          licenses: ['Foo License'],
        })
        @gem.send(:render_gemspec_options)
      end

      it 'should replace the singulars' do
        expect(@gem.project_options[:gemspec_string]).to include 's.authors = ["Foo Author"]'
        expect(@gem.project_options[:gemspec_string]).to_not include 's.author = '
        expect(@gem.project_options[:gemspec_string]).to include 's.licenses = ["Foo License"]'
        expect(@gem.project_options[:gemspec_string]).to_not include 's.license = '
      end
    end
  end

  describe '#extract_gem_dependencies' do
    before do
      stub_const 'New::Task::Gem::GEMFILE', root('spec', 'fixtures', 'tasks', 'foo_task', 'Gemfile')
    end

    it 'should set dependencies' do
      gem_dependencies = @gem.send(:extract_gem_dependencies)
      expect(gem_dependencies).to include "  s.add_runtime_dependency 'foo', '~> 1.2.3'"
      expect(gem_dependencies).to include "  s.add_development_dependency 'bar', '>= 0'"
    end
  end

  describe '#write_gemspec' do
    before do
      allow(@gem).to receive(:project_options).and_return({ gemspec_string: 'foo' })
      @gem.send(:write_gemspec)
    end

    after do
      allow(@gem).to receive(:project_options).and_call_original
    end

    it 'should write a gemspec file' do
      expect(File.exist?('.gemspec')).to eq true
    end

    it 'should be a valid gemspec file' do
      gemspec = File.read('.gemspec')
      expect(gemspec).to include 'Gem::Specification.new'
      expect(gemspec).to include 'foo'
    end
  end

  describe '#write_config' do
    before do
      allow(@gem).to receive(:project_options).and_return({
        gemspec_string: 'foo',
        foo_files: 'foo',
        bar: 'bar'
      })
      @gem.send(:write_config)
    end

    after do
      allow(@gem).to receive(:project_options).and_call_original
    end

    it 'should update the config file' do
      config = File.read(New::CONFIG_FILE)
      expect(config).to_not include 'foo'
      expect(config).to include 'bar: bar'
    end
  end
end
