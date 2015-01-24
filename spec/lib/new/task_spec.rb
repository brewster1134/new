describe New::Task do
  before do
    New::Task.new root('spec', 'fixtures', 'task', 'task_task.rb')
  end

  it 'should add to global tasks' do
    expect(New::Task.class_var(:tasks)[:task]).to eq Task
  end
end
