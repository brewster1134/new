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

  describe '.find_task' do
    before do
      New::Source.class_var :sources, {
        :foo_source => OpenStruct.new({:tasks => { :foo => 'Foo Source Foo Task' }}),
        :bar_source => OpenStruct.new({:tasks => { :foo => 'Bar Source Foo Task' }})
      }
    end

    context 'when a source is specified' do
      it 'should return the task from the source' do
        expect(New::Source.find_task(:foo, :bar_source)).to eq 'Bar Source Foo Task'
      end
    end

    context 'when a source is not specified' do
      it 'should look through sources and return the first matching task' do
        expect(New::Source.find_task(:foo)).to eq 'Foo Source Foo Task'
      end
    end
  end

  describe '#initialize' do
    before do
      allow(New::Task).to receive(:get_task_name).and_return :source_spec_task_name
      allow(New::Task).to receive(:tasks).and_return({ :source_spec_task_name => 'Task Class' })
      @source = New::Source.new root('spec', 'fixtures')
    end

    after do
      allow(New::Task).to receive(:get_task_name).and_call_original
      allow(New::Task).to receive(:tasks).and_call_original
    end

    it 'should collect tasks' do
      expect(@source.instance_var(:tasks)[:source_spec_task_name]).to eq 'Task Class'
    end
  end
end
