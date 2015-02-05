describe New::Task do
  before :all do
  end

  describe '.inherited' do
    before do
      @task = New::TaskTask.new({})
    end

    it 'should assign to the subclass' do
      expect(@task.path).to ending_with 'task_task.rb'
      expect(@task.name).to eq :task
    end

    it 'should add to global object' do
      expect(New::Task.tasks[:task]).to eq New::TaskTask
    end
  end

  describe '#bundle_install' do
    before do
      @task = New::TaskTask.new({})
      allow(@task).to receive(:system)
      @task.bundle_install
    end

    after do
      allow(@task).to receive(:system).and_call_original
    end

    it 'should run bundler with task Gemfile' do
      expect(@task).to have_received(:system).with starting_with 'bundle install --gemfile='
      expect(@task).to have_received(:system).with ending_with '/task/Gemfile'
    end
  end
end
