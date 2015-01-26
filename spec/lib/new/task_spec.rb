describe New::Task do
  context '.load & .inherited' do
    before :all do
      New::Task.load root('spec', 'fixtures', 'task', 'task_task.rb')
    end

    it 'should add task to global array' do
      expect(New::Task.class_var(:tasks)[:task]).to eq Task
    end
  end
end
