describe New::Source do
  before do
    dbl = double
    allow(dbl).to receive(:files).and_return ['/task/path/task_task.rb']
    allow(Sourcerer).to receive(:new).and_return dbl
  end

  after do
    allow(Sourcerer).to receive(:new).and_call_original
  end

  describe '.load_sources' do
    before do
      New.class_var :new_object, {
        :sources => {
          :foo => '/foo/path'
        }
      }

      New::Source.load_sources
    end

    it 'should collect initialized sources' do
      expect(New::Source.sources[:foo]).to be_a New::Source
    end
  end

  describe '#initialize' do
    before do
      @source = New::Source.new root('spec', 'fixtures')
    end

    it 'should collect tasks' do
      expect(@source.tasks['path']).to be_a New::Task
    end
  end
end
