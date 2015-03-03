describe New::Source do
  # sources are preloaded in spec_helper
  #
  describe '.load_sources' do
    it 'should collect initialized sources' do
      expect(New::Source.class_var(:sources)[:spec]).to be_a New::Source
    end
  end

  describe '.find_task' do
    before do
      New::Source.class_var(:sources).merge!({
        :foo_source => OpenStruct.new({:tasks => { :foo => 'Foo Source Foo Task' }}),
        :bar_source => OpenStruct.new({:tasks => { :foo => 'Bar Source Foo Task' }})
      })
    end

    after do
      New::Source.class_var(:sources).delete(:foo_source)
      New::Source.class_var(:sources).delete(:bar_source)
    end

    context 'when a source is specified' do
      it 'should return the task from the source' do
        expect(New::Source.find_task(:foo, :bar_source)).to eq 'Bar Source Foo Task'
      end
    end

    context 'when a source is not specified' do
      it 'should search the sources and return the first matching task' do
        expect(New::Source.find_task(:foo)).to eq 'Foo Source Foo Task'
      end
    end

    context 'when a source is specified with the `#` format' do
      it 'should search the sources and return the first matching task' do
        expect(New::Source.find_task('foo_source#foo')).to eq 'Foo Source Foo Task'
      end
    end
  end

  describe '#initialize' do
    before do
      @source = New::Source.class_var(:sources)[:spec]
    end

    it 'should collect tasks' do
      expect(@source.tasks[:task]).to be_a New::Task
    end

    it 'should set the path' do
      expect(@source.instance_var(:path)).to ending_with '/spec/fixtures/source'
    end
  end
end
