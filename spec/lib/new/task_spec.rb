require 'spec_helper'
require 'yaml'

class New::Task::TaskSpec < New::Task
  OPTIONS = {
    default: true
  }
  def run; end
end

describe New::Task do
  let(:task){ New::Task::TaskSpec.new YAML.load(File.open(root('spec', 'fixtures', 'project', '.new'))).deep_symbolize_keys! }

  describe '.inherited' do
    it 'should create a name from the class name' do
      expect(task.class.name).to eq :task_spec
    end
  end

  describe 'instances' do
    before do
      task.stub(:name).and_return(:foo_task)
    end

    after do
      task.unstub(:name)
    end

    it 'should not merge other tasks in' do
      # make sure the custom config has the extra task, and make sure it doesnt come through to the task
      expect(YAML.load(File.open(root('spec', 'fixtures', 'custom', New::CONFIG_FILE))).deep_symbolize_keys![:tasks].has_key?(:dont_include)).to be_true
      expect(task.project_options[:tasks].has_key?(:dont_include)).to be_false
    end

    it 'should get the correct task options' do
      expect(task.options).to eq({ foo: 'project', project: true, custom: true, default: true })
    end
  end
end
