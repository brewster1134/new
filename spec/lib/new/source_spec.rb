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

    it 'should collect initialized sources' do
      expect(New::Source.class_var(:sources)[:foo]).to eq 'new source'
    end
  end

  describe '#initialize' do
    before do
      allow(New::Task).to receive(:new).and_return 'new_task'

      @source = New::Source.new root('spec', 'fixtures')
    end

    after do
      allow(Sourcerer).to receive(:new).and_call_original
      allow(New::Task).to receive(:new).and_call_original
    end

    it 'should collect tasks' do
      expect(@source.instance_var(:tasks)['task']).to eq 'new_task'
    end
  end
end
