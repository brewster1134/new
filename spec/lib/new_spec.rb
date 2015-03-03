describe New do
  # Newfiles are preloaded in spec_helper
  #
  describe '.load_newfiles' do
    it 'should add home & project Newfile symbolized data to global new object' do
      expect(New.new_object).to eq({
        :name => 'Project Fixture',
        :version => '1.2.3',
        :sources => {
          :spec => 'spec/fixtures/source'
        },
        :tasks => {
          :task => {
            :source => 'spec'
          }
        }
      })
    end
  end

  describe '.cli' do
    before do
      New.class_var :cli, false
      New.set_cli
    end

    it 'should toggle cli to true' do
      expect(New.class_var(:cli)).to eq true
    end
  end

  describe '#initialize' do
    before do
      @task = New::Task.tasks[:task]

      allow(@task).to receive(:run)
      allow(New::Source).to receive(:find_task).and_call_original

      New.new '1.2.4'
    end

    after do
      allow(@task).to receive(:run).and_call_original
      allow(New::Source).to receive(:find_task).and_call_original
    end

    it 'should add new version' do
      expect(New.new_object[:version]).to eq '1.2.4'
    end

    it 'should lookup task from source' do
      expect(New::Source).to have_received(:find_task).with :task, :spec
    end

    it 'should call run on tasks' do
      expect(@task).to have_received(:run)
    end
  end
end
