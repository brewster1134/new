require 'spec_helper'

describe New::Template do
  before :all do
    Dir.chdir root('.tmp')
  end

  before do
    stub_const 'New::TEMPLATES_DIR', root('spec', 'fixtures', 'templates')
    stub_const 'New::Template::CUSTOM_CONFIG_FILE', root('spec', 'fixtures', 'new_default')
  end

  after do
    FileUtils.rm_rf root('.tmp', 'new_foo')
  end

  describe 'new project structure' do
    let(:project_config) { YAML.load(File.open(root('.tmp', @template.options[:name], '.new'))).deep_symbolize_keys! }

    context 'when no custom template is defined' do
      before do
        @template = New::Template.new :foo, { name: 'new_foo' }
      end

      it 'should set the template' do
        expect(@template.template).to eq :foo
      end

      it 'should create a new directory with the project name' do
        expect(Dir.exists?(root('.tmp', @template.options[:name]))).to eq true
      end

      it 'should create a `.new` config file' do
        expect(File.exists?(root('.tmp', @template.options[:name], '.new'))).to eq true
      end

      it 'should add all the neccessary yaml info' do
        expect(project_config[:template]).to eq :foo
        expect(project_config[:project_name]).to eq 'new_foo'
        expect(project_config[:developer][:name]).to eq 'Foo Bar'
        expect(project_config[:developer][:email]).to eq 'foo@bar.com'
        expect(project_config[:license]).to eq 'MIT'
      end

      it 'should process and rename .erb files' do
        # check that files exist
        expect(File.exists?(root('.tmp', @template.options[:name], 'foo.txt'))).to eq true
        expect(File.exists?(root('.tmp', @template.options[:name], 'nested', 'foo.txt'))).to eq true

        # check their content has been processed
        expect(File.open(root('.tmp', @template.options[:name], 'foo.txt')).read).to include 'foo bar'
        expect(File.open(root('.tmp', @template.options[:name], 'nested', 'foo.txt')).read).to include 'foo bar'
      end
    end

    context 'when a custom template is defined' do
      before do
        stub_const 'New::Template::CUSTOM_TEMPLATES', root('spec', 'fixtures', 'custom_templates')
        @template = New::Template.new :foo, { name: 'new_foo' }
      end

      it 'should add the custom value' do
        expect(project_config[:custom]).to eq true
      end

      it 'should use files from the custom template' do
        expect(File.exists?(root('.tmp', @template.options[:name], 'custom_foo.txt'))).to eq true
      end
    end
  end
end
