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

#   before do
#     allow_any_instance_of(New::Template).to receive(:interpolate)
#   end

#   after do
#     allow_any_instance_of(New::Template).to receive(:interpolate).and_call_original
#   end




#   describe '#template_dir' do
#     context 'with a default template' do
#       let(:type){ :foo_template }

#       it 'should return the default template path' do
#         expect(template.send(:template_dir)).to eq File.join(New::DEFAULT_DIR, New::TEMPLATES_DIR_NAME, type.to_s)
#       end
#     end

#     context 'with a custom template' do
#       let(:type){ :custom_bar_template }

#       it 'should return the custom template path' do
#         expect(template.send(:template_dir)).to eq File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, type.to_s)
#       end

#       it 'should set the custom flag' do
#         expect(template.instance_variable_get('@custom')).to eq true
#       end
#     end
#   end

#   describe '#options' do
#     before do
#       stub_const('New::Template::CUSTOM_CONFIG_TEMPLATE', { default: true })
#     end

#     it 'should build complete options' do
#       options = template.send(:options)

#       # check default template options
#       expect(options[:default]).to eq true

#       # check template options
#       expect(options[:template]).to eq true

#       # check custom config options
#       expect(options[:custom]).to eq true

#       # check project specific options
#       expect(options[:type]).to eq('foo_template')
#       expect(options[:project][:name]).to eq('new_template')
#     end
#   end
# end
