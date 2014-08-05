require 'spec_helper'
require 'recursive-open-struct'

describe New::Project do

  before do
    # set pwd to a temp folder to create the new project in
    @original_dir = Dir.pwd
    Dir.chdir Dir.mktmpdir

    allow(New).to receive(:global_options).and_return({
      global_options: true
    })

    allow(New::Template).to receive(:new).and_return RecursiveOpenStruct.new({
      dir: root('spec', 'fixtures', 'foo_template'),
      options: {
        template_options: true
      }
    })

    @project = New::Project.new :foo_template, :new_project
  end

  after do
    Dir.chdir @original_dir
    allow(New::Template).to receive(:new).and_call_original
  end

  it 'should copy the template' do
    expect(Dir.exists?(@project.instance_var(:project_dir))).to eq true
  end

  it 'should create a config file' do
    expect(YAML.load(File.read(File.join(@project.instance_var(:project_dir), New::CONFIG_FILE)))).to eq({
      'global_options' => true,
      'template_options' => true
    })
  end
end
