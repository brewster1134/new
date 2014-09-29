require 'spec_helper'

describe New do
  before do
    stub_const 'New::GLOBAL_CONFIG_FILE', root('spec', 'fixtures', 'home_folder_new')
  end

  it 'should return the global configuration' do
    expect(New.global_config[:developer][:name]).to eq 'Foo Bar'
  end

  it 'should return a version' do
    expect{ Semantic::Version.new(New.version) }.to_not raise_error
  end
end
