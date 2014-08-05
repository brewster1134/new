require 'spec_helper'
require 'yaml'

class New::TaskSpec < New::Task
  OPTIONS = { task_spec: false }
end

describe New::Task do
  before do
    allow(New).to receive(:global_config).and_return({ global_options: true })
    allow_any_instance_of(New::TaskSpec).to receive(:run)

    @task = New::TaskSpec.new({
      project_options: true,
      tasks: {
        task_options: true,
        foo_options: false
      }
    })
  end

  after do
    allow(New).to receive(:global_config).and_call_original
  end

  it 'should get the correct project options' do
    expect(@task.project.options).to eq({
      global_options: true,
      project_options: true,
      task_spec: { task_options: true }
    })
  end

  it 'should get the correct task options' do
    expect(@task.options).to eq({ task_options: true })
  end

  it 'should call the run method' do
    expect(@task).to have_received(:run)
  end
end
