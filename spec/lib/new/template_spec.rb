require 'spec_helper'

describe New::Template do
  let(:project_name) { 'new_foo' }
  let(:template) { New::Template.new(:foo_template, project_name) }
  let(:options) { template.instance_variable_get '@template_options' }
  let(:project_config) { YAML.load(File.open(root('.tmp', options.project_name, New::CONFIG_FILE))).deep_symbolize_keys! }

  before :all do
    Dir.chdir root('.tmp')
  end

  before do
    stub_const 'New::DEFAULT_DIR', root('spec', 'fixtures')
    stub_const 'New::CUSTOM_DIR', root('spec', 'fixtures', 'custom')
  end

  after do
    FileUtils.rm_rf root('.tmp', project_name)
  end

  describe 'new project structure' do
    it 'should access option values directly in dot notation' do
      expect(template.developer.name).to_not be_nil
    end

    it 'should set the template' do
      expect(options.type).to eq :foo_template
    end

    it 'should not add the custom value' do
      expect(project_config[:custom]).to be_nil
    end

    it 'should create a new directory with the project name' do
      expect(Dir.exists?(root('.tmp', options.project_name))).to eq true
    end

    it 'should create a `.new` config file' do
      expect(File.exists?(root('.tmp', options.project_name, New::CONFIG_FILE))).to eq true
    end

    it 'should add all the neccessary yaml info' do
      expect(project_config[:type]).to eq :foo_template
      expect(project_config[:project_name]).to eq project_name
      expect(project_config[:developer][:name]).to eq 'Foo Bar'
      expect(project_config[:developer][:email]).to eq 'foo@bar.com'
      expect(project_config[:license]).to eq 'MIT'
      expect(project_config[:tasks]).to eq [:foo] # from template specific config file
    end

    it 'should process and rename .erb files' do
      # check that files exist
      expect(File.exists?(root('.tmp', options.project_name, 'Foo Bar.txt'))).to eq true
      expect(File.exists?(root('.tmp', options.project_name, 'nested_foo_template', 'foo.txt'))).to eq true

      # check their content has been processed
      expect(File.open(root('.tmp', options.project_name, 'Foo Bar.txt')).read).to include 'template foo'
      expect(File.open(root('.tmp', options.project_name, 'nested_foo_template', 'foo.txt')).read).to include 'foo bar'
    end

    context 'when a custom template is defined' do
      let(:template) { New::Template.new(:custom_bar_template, project_name) }

      it 'should add the custom value' do
        expect(project_config[:custom]).to eq true
      end

      it 'should use files from the custom template' do
        expect(File.exists?(root('.tmp', options.project_name, 'custom_bar.txt'))).to eq true
      end
    end
  end
end
