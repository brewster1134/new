require 'spec_helper'
require 'recursive-open-struct'

describe New::Project do
  let(:template_dir){ File.join(New::TEMP_DIR, 'custom_bar_template') }
  let(:project_dir){ File.join(New::TEMP_DIR, 'new_project') }
  let(:project){ New::Project.new(:custom_bar_template, :new_project) }
  let(:project_config) { YAML.load(File.open(File.join(project_dir, New::CONFIG_FILE))).deep_symbolize_keys! }

  before do
    Dir.chdir New::TEMP_DIR
    FileUtils.cp_r root('spec', 'fixtures', 'custom', 'templates', 'custom_bar_template'), New::TEMP_DIR
    New::Template.stub(:new).and_return(RecursiveOpenStruct.new({ options: {}, dir: template_dir }))
    project
  end

  after do
    New::Template.unstub(:new)
    FileUtils.rm_rf template_dir
    FileUtils.rm_rf project_dir
  end

  it 'should copy the template' do
    expect(Dir.exists?(project_dir)).to eq true
  end

  it 'should create a config file' do
    expect(File.exists?(File.join(project_dir, New::CONFIG_FILE))).to eq true
  end
end
