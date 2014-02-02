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

    it 'should get the correct task options' do
      expect(task.options).to eq({ foo: 'project', project: true, custom: true, default: true })
    end
  end
end
