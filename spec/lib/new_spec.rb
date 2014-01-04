require 'spec_helper'

describe New do
  it 'should return a version' do
    expect(New::VERSION).to_not be_nil
  end

  it 'should return an array of available templates' do
    expect(New::templates).to match_array [:js]
  end
end
