describe New do
  before do
    @task = New::Task.tasks[:task]
    @task_two = New::Task.tasks[:task_two]
    allow(@task).to receive(:validate)
    allow(@task_two).to receive(:validate)
    allow(@task).to receive(:verify).and_call_original
    allow(@task).to receive(:run).and_call_original
    allow(@task_two).to receive(:verify).and_call_original
    allow(@task_two).to receive(:run).and_call_original

    allow(File).to receive(:open)
    allow(New::Source).to receive(:find_task).and_call_original
  end

  after do
    allow(@task).to receive(:validate).and_call_original
    allow(@task_two).to receive(:validate).and_call_original

    allow(File).to receive(:open).and_call_original
  end

  # Newfiles are preloaded in spec_helper
  #
  describe '.load_newfiles' do
    it 'should add home & project Newfile symbolized data to global new object' do
      expect(New.new_object).to include({
        :name => 'Project Fixture',
        :version => '1.2.3',
        :sources => {
          :spec => 'spec/fixtures/source'
        },
        :tasks => {
          :task => {
            :source => 'spec'
          },
          :task_two => {
            :source => 'spec'
          }
        }
      })
    end
  end

  describe '.set_cli' do
    before do
      New.class_var :cli, false
      New.set_cli
    end

    it 'should toggle cli to true' do
      expect(New.class_var(:cli)).to eq true
    end
  end

  describe '#initialize' do
    context 'with all tasks' do
      before do
        @expected_options = {
          :name => 'Project Fixture',
          :version => '1.2.4',
          :changelog => ['changelog'],
          :task_options => {}
        }

        New.new '1.2.4', ['changelog']
      end

      it 'should add new attributes to the global object' do
        expect(New.new_object[:version]).to eq '1.2.4'
        expect(New.new_object[:changelog]).to eq ['changelog']
      end

      it 'should lookup task from source' do
        expect(New::Source).to have_received(:find_task).with :task, 'spec'
      end

      it 'should call verify on tasks' do
        expect(@task).to have_received(:verify)
        expect(@task.instance_var(:verified)).to eq true
      end

      it 'should call run on tasks' do
        expect(@task).to have_received(:run)
        expect(@task.instance_var(:ran)).to eq true
      end

      it 'should run all verify methods before any run methods' do
        expect(@task).to have_received(:verify).ordered
        expect(@task_two).to have_received(:verify).ordered
        expect(@task).to have_received(:run).ordered
        expect(@task_two).to have_received(:run).ordered
      end

      it 'should set instance options' do
        expect(@task.instance_var(:options)).to eq @expected_options
        expect(@task_two.instance_var(:options)).to eq @expected_options
      end
    end

    context 'when skipping tasks' do
      before do
        New.new '1.2.4', ['changelog'], 'task'
      end

      it 'should skip task' do
        expect(@task).to_not have_received(:verify)
        expect(@task).to_not have_received(:run)
        expect(@task_two).to have_received(:verify)
        expect(@task_two).to have_received(:run)
      end
    end
  end
end
