describe New::Source do
  describe '.load_sources' do
    before do
      allow(New::Source).to receive(:new).and_return 'new source'

      New.class_var :new_object, {
        :sources => {
          :foo => '/foo/path'
        }
      }

      New::Source.load_sources
    end

    after do
      allow(New::Source).to receive(:new).and_call_original
    end

    it 'should collect initialized sources' do
      expect(New::Source.class_var(:sources)[:foo]).to eq 'new source'
    end
  end

  describe '.find_task_path' do
    before do
      New::Source.class_var :sources, {
        :foo_source => OpenStruct.new({:tasks => { :foo => 'Foo Source Foo Task' }}),
        :bar_source => OpenStruct.new({:tasks => { :foo => 'Bar Source Foo Task' }})
      }
    end

    context 'when a source is specified' do
      it 'should return the task from the source' do
        expect(New::Source.find_task_path(:foo, :bar_source)).to eq 'Bar Source Foo Task'
      end
    end

    context 'when a source is not specified' do
      it 'should look through sources and return the first matching task' do
        expect(New::Source.find_task_path(:foo)).to eq 'Foo Source Foo Task'
      end
    end
  end

  describe '#initialize' do
    before do
      @source = New::Source.new root('spec', 'fixtures')
    end

    it 'should collect tasks' do
      expect(@source.instance_var(:tasks)[:task]).to end_with 'task/task_task.rb'
    end
  end
end
