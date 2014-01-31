require 'spec_helper'

describe New::Project do
  let(:project_config) { YAML.load(File.open(root('.tmp', 'new_project', New::CONFIG_FILE))).deep_symbolize_keys! }

  before do
    Dir.chdir root('.tmp')
    New::Template.stub(:new).and_return(RecursiveOpenStruct.new({ options: {}, dir: root('spec', 'fixtures', 'templates', 'custom_bar_template') }))
    New::Project.new(:foo_template, 'new_project')
  end

  after do
    New::Template.unstub(:new)
    FileUtils.rm_rf root('.tmp', 'new_project')
  end

  it 'should copy the template' do
    expect(Dir.exists?(root('.tmp', 'new_project'))).to eq true
  end

  it 'should create a config file' do
    expect(File.exists?(root('.tmp', 'new_project', New::CONFIG_FILE))).to eq true
  end
end
