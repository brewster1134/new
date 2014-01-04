require 'spec_helper'

describe New::Template do
  before :all do
    Dir.chdir root('.tmp')
  end

  before do
    stub_const 'New::Template::TEMPLATES_DIR', root('spec', 'fixtures', 'templates')
    @template = New::Template.new :foo, { name: 'new_foo' }
  end

  after do
    FileUtils.rm_rf root('.tmp', 'new_foo')
  end

  it 'should set the template' do
    expect(@template.template).to eq :foo
  end

  it 'should create a new directory with the project name' do
    expect(Dir.exists?(root('.tmp', @template.options[:name]))).to eq true
  end

  it 'should create a `.new` config file with the template defined' do
    expect(File.exists?(root('.tmp', @template.options[:name], '.new'))).to eq true
    expect(File.open(root('.tmp', @template.options[:name], '.new')).read).to include 'template: :foo'
  end

  it 'should process .erb files' do
    expect(File.exists?(root('.tmp', @template.options[:name], 'foo.txt'))).to eq true
    expect(File.exists?(root('.tmp', @template.options[:name], 'nested', 'foo.txt'))).to eq true
    expect(File.open(root('.tmp', @template.options[:name], 'foo.txt')).read).to include 'foo bar'
    expect(File.open(root('.tmp', @template.options[:name], 'nested', 'foo.txt')).read).to include 'foo bar'
  end
end
