require 'spec_helper'

describe New::Task do
  let(:task){ New::Task::TaskSpec.new }

  describe '.inherited' do
    before do
      class New::Task::TaskSpec < New::Task
        def initialize; end
      end
    end

    it 'should create a name form the class name' do
      expect(New::Task.instance_variable_get('@name')).to eq :task_spec
    end
  end

  describe 'instances' do
    before do
      task.instance_variable_set '@name', :foo_task
    end

    it 'should get the correct task options' do
      expect(task.class.send(:get_options)).to eq({ foo: 'project', project: true, custom: true, default: true })
    end
  end
end
