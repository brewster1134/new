require 'spec_helper'

class VersionSpec
  include New::Version
end

describe New::Version do
  let(:version){ VersionSpec.new }

  describe '#bump_version' do
    it 'should bump the major version' do
      expect(version.bump_version('1.2.3', :major).to_s).to eq '2.0.0'
    end

    it 'should bump the minor version' do
      expect(version.bump_version('1.2.3', :minor).to_s).to eq '1.3.0'
    end

    it 'should bump the patch version' do
      expect(version.bump_version('1.2.3', :patch).to_s).to eq '1.2.4'
    end
  end
end
