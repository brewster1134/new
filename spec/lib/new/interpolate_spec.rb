require 'spec_helper'

class InterpolateSpec
  include New::Interpolate
end

describe New::Interpolate do
  before do
    tmp_dir = Dir.mktmpdir
    FileUtils.cp_r root('spec', 'fixtures', 'foo_template'), tmp_dir

    @template_dir = File.join(tmp_dir, 'foo_template')

    @obj = InterpolateSpec.new
    @obj.interpolate @template_dir, { foo: { :bar => :baz }}
  end

  it 'should process and rename .erb files' do
    expect(File.open(File.join(@template_dir.dir, 'baz.txt')).read).to include 'foo baz'
  end

  it 'should create dot notation accessible options' do
    expect(@obj.options.foo.bar).to eq('baz')
  end
end
