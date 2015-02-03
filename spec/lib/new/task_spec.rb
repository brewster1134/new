describe New::Task do
  before do
    allow(New::Task).to receive(:system)
    @task = New::Task.load root('spec', 'fixtures', 'task', 'task_task.rb')
  end

  after do
    allow(New::Task).to receive(:system).and_call_original
  end

  describe.skip '.load' do
    it 'should require the task' do
      expect(New::Task).to receive(:require).with root('spec', 'fixtures', 'task', 'task_task')
    end

    it 'should install gems' do
      expect(New::Task).to receive(:system).with "bundle install --gemfile=#{root('spec', 'fixtures', 'task', 'Gemfile')}"
    end
  end

  context '.inherited' do
    it 'should add task to global array' do
      expect(New::Task.class_var(:tasks)[:task]).to eq New::TaskTask
    end
  end
end
