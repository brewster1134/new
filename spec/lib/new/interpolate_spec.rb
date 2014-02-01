require 'spec_helper'

class InterpolateSpec
  include New::Interpolate
end

describe New::Interpolate do
  let(:template_dir){ root('spec', 'fixtures', 'templates', 'foo_template') }

  before do
    @obj = InterpolateSpec.new
    @obj.interpolate(template_dir, {
      'foo' => {
        'bar' => 'baz'
      }
    })
  end

  after do
    FileUtils.rm_rf @obj.dir
  end

  it 'should process and rename .erb files' do
    # check that files exist
    expect(File.exists?(File.join(@obj.dir, 'baz.txt'))).to eq true
    expect(File.exists?(File.join(@obj.dir, 'nested_baz', 'foo.txt'))).to eq true

    # check their content has been processed
    expect(File.open(File.join(@obj.dir, 'baz.txt')).read).to include 'foo baz'
    expect(File.open(File.join(@obj.dir, 'nested_baz', 'foo.txt')).read).to include 'foo baz'
  end

  it 'should create dot notation accessible options' do
    expect(@obj.options.foo.bar).to eq('baz')
  end

  it 'should respond to options as methods' do
    expect(@obj.foo.bar).to eq 'baz'
  end
end
