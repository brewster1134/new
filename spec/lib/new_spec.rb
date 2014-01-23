require 'spec_helper'

describe New do
  before do
    stub_const 'New::DEFAULT_DIR', root('spec', 'fixtures')
    stub_const 'New::CUSTOM_DIR', root('spec', 'fixtures', 'custom')
  end

  it 'should return a version' do
    expect(New::VERSION).to match /[0-9]+.[0-9]+.[0-9]+/
  end

  it 'should return an array of available tasks' do
    expect(New.tasks).to match_array [:foo_task, :custom_bar_task]
    expect(New.default_tasks).to match_array [:foo_task, :custom_bar_task]
    expect(New.custom_tasks).to match_array [:custom_bar_task]
  end

  it 'should return an array of available templates' do
    expect(New.templates).to match_array [:foo_template, :custom_bar_template]
    expect(New.default_templates).to match_array [:foo_template, :custom_bar_template]
    expect(New.custom_templates).to match_array [:custom_bar_template]
  end
end
