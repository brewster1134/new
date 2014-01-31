require 'spec_helper'

class InterpolateSpec
  include New::Interpolate
end

describe New::Interpolate do
  let(:obj) { InterpolateSpec.new }
  let(:root_path){ File.join(New::TEMP_DIR, 'foo_template') }

  before do
    FileUtils.cp_r root('spec', 'fixtures', 'templates', 'foo_template'), New::TEMP_DIR
  end

  after do
    FileUtils.rm_rf root_path
  end

  describe '#create_dot_options' do
    before do
      obj.create_dot_options({
        'foo' => {
          'bar' => 'baz'
        }
      })
    end

    it 'should create dot notation accessible options' do
      expect(obj.options.foo.bar).to eq('baz')
    end
  end

  describe '#process_paths & #process_files' do
    before do
      obj.create_dot_options({
        'boo' => 'far',
        'foo' => {
          'bar' => 'baz'
        }
      })
      obj.process_paths root_path
      obj.process_files root_path
    end

    it 'should process and rename .erb files' do
      # check that files exist
      expect(File.exists?(File.join(root_path, 'baz.txt'))).to eq true
      expect(File.exists?(File.join(root_path, 'nested_far', 'foo.txt'))).to eq true

      # check their content has been processed
      expect(File.open(File.join(root_path, 'baz.txt')).read).to include 'template far'
      expect(File.open(File.join(root_path, 'nested_far', 'foo.txt')).read).to include 'foo far'
    end
  end

  describe '#method_missing' do
    before do
      obj.create_dot_options({
        'foo' => {
          'bar' => 'baz'
        }
      })
    end

    it 'should respond to options as methods' do
      expect(obj.foo.bar).to eq 'baz'
    end
  end
end
