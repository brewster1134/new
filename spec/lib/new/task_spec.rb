describe New::Task do
  describe '.inherited' do
    before do
      # task fixture is already loaded in spec_helper
      @task = New::Task.tasks[:task]
    end

    it 'should initialize sub-task' do
      expect(@task.instance_var(:path)).to ending_with 'task_task.rb'
      expect(@task.instance_var(:name)).to eq :task
    end

    it 'should add to global object' do
      # since task class is unloaded after it is initialized, can't test again actual class name
      expect(@task.class.to_s).to eq 'New::TaskTask'
      expect(@task).to be_a New::Task
    end
  end

  describe '.get_task_name' do
    it 'should convert task path to symbolized task name' do
      expect(New::Task.send(:get_task_name, '/path/to/foo_bar_task.rb')).to eq :foo_bar
    end
  end
end
