require 'spec_helper'

describe New::Template do
  before do
    allow_any_instance_of(New::Template).to receive(:interpolate)
    allow_any_instance_of(New::Template).to receive(:template_options).and_return({
      name: 'foo_template',
      foo_option: 'template',
      bar_option: 'template'
    })

    allow(New).to receive(:global_config).and_return({
      global_options: true,
      templates: {
        foo_template: {
          foo_option: 'global'
        },
        bar_template: {}
      }
    })

    @template = New::Template.new :foo_template, RecursiveOpenStruct.new({
      name: 'Foo Project',
      filename: 'foo_project'
    })
  end

  after do
    allow_any_instance_of(New::Template).to receive(:interpolate).and_call_original
    allow_any_instance_of(New::Template).to receive(:template_options).and_call_original
    allow(New).to receive(:global_config).and_call_original
  end

  it 'should return the template source directory' do
    expect(@template.dir).to eq(root('spec', 'fixtures', 'foo_template'))
  end

  it 'should return options' do
    # verify global options
    expect(@template.options[:global_options]).to eq true

    # verify template options
    expect(@template.options[:template]).to eq ({
      name: 'foo_template',
      foo_option: 'global',
      bar_option: 'template'
    })

    # verify project options
    expect(@template.options[:project]).to eq ({
      name: 'Foo Project',
      filename: 'foo_project'
    })
  end

  it 'should not return other template options' do
    expect(@template.options[:templates]).to be nil
  end
end
