require 'spec_helper'

class VersionSpec
  include New::Version
end

describe New::Version do
  let(:version){ VersionSpec.new }

  describe '#bump_version' do
    it 'should bump the major version' do
      version.bump_version('1.2.3', :major)
      expect(version.version.to_s).to eq '2.0.0'
    end

    it 'should bump the minor version' do
      version.bump_version('1.2.3', :minor)
      expect(version.version.to_s).to eq '1.3.0'
    end

    it 'should bump the patch version' do
      version.bump_version('1.2.3', :patch)
      expect(version.version.to_s).to eq '1.2.4'
    end
  end
end
