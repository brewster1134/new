require 'spec_helper'

describe New::Template do
  subject(:template){ New::Template.new type, 'new_template' }

  describe 'with a custom template' do
    let(:type){ :custom_bar_template }

    before do
      New.stub(:custom_templates).and_return([type])
    end

    after do
      New.unstub(:custom_templates)
      FileUtils.rm_rf root('.tmp', type)
    end

    it 'should set the custom template dir' do
      expect(template.instance_variable_get('@source_template_dir')).to eq File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, type.to_s)
    end

    it 'should set the custom boolean' do
      expect(template.instance_variable_get('@custom')).to be_true
    end

    it 'should build template options' do
      expect(template.send(:get_template_config)).to eq({ tasks: { foo_task: nil, custom_bar_task: nil }, custom: true })
    end

    it 'should set the custom template dir' do
      expect(template.instance_variable_get('@source_template_dir')).to eq File.join(New::CUSTOM_DIR, New::TEMPLATES_DIR_NAME, type.to_s)
    end
  end

  describe 'with a default template' do
    let(:type){ :foo_template }

    before do
      New::Interpolate.instance_methods.each{ |m| New::Template.any_instance.stub(m) }
      New.stub(:custom_templates).and_return([])
    end

    after do
      New::Interpolate.instance_methods.each{ |m| New::Template.any_instance.unstub(m) }
      New.unstub(:custom_templates)
      FileUtils.rm_rf root('.tmp', type)
    end

    it 'should set the custom template dir' do
      template.send(:copy_template)
      expect(Dir.exists?(root('.tmp', type))).to be_true
      expect(template.instance_variable_get('@dest_template_dir')).to eq root('.tmp', type)
    end
  end
end
