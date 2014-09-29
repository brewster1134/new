require 'spec_helper'

describe New::Source do
  before do
    @source = New::Source.new root('spec', 'fixtures')
  end

  it 'should collect all tasks' do
    expect(@source.tasks).to match_array [:foo_task]
  end

  it 'should collect all templates' do
    expect(@source.templates).to match_array [:foo_template]
  end
end
