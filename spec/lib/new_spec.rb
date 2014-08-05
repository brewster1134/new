require 'spec_helper'

describe New do
  it 'should return a version' do
    expect{ Semantic::Version.new(New.version) }.to_not raise_error
  end

  it 'should return an array of available tasks' do
    expect(New.tasks).to match_array [:foo_task]
  end

  it 'should return an array of available templates' do
    expect(New.templates).to match_array [:foo_template]
  end
end
