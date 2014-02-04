require 'spec_helper'

class VersionSpec
  include New::Version
end

describe New::Version do
  let(:version){ VersionSpec.new }

  before do
    version.version = '1.2.3'
  end

  it 'should set a version' do
    expect(version.version.to_s).to eq '1.2.3'
  end

  it 'should bump the version' do
    version.bump_version :major
    expect(version.version.to_s).to eq '2.2.3'

    version.bump_version :minor
    expect(version.version.to_s).to eq '2.3.3'

    version.bump_version :patch
    expect(version.version.to_s).to eq '2.3.4'
  end
end
