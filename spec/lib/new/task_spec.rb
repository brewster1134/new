describe New::Task do
  before do
    # task fixture is already loaded in spec_helper
    @task = New::Task.tasks[:task]
  end

  describe '.inherited' do
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

  describe '#run_command' do
    before do
      allow(Kernel).to receive(:system)
    end

    after do
      allow(Kernel).to receive(:system).and_call_original
    end

    context 'when in verbose mode' do
      before do
        allow(New).to receive(:verbose).and_return true
      end

      it 'should call system without redirecting to null' do
        expect(Kernel).to receive(:system).with 'ruby -v'
        @task.run_command 'ruby -v'
      end
    end

    context 'when not in verbose mode' do
      before do
        allow(New).to receive(:verbose).and_return false
      end

      it 'should call system and redirect to null' do
        expect(Kernel).to receive(:system).with 'ruby -v >> /dev/null 2>&1'
        @task.run_command 'ruby -v'
      end
    end
  end
end
