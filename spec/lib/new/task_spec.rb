describe New::Task do
  before do
    @task = New::Task.tasks[:task]
  end

  # task fixture is already loaded in spec_helper
  #
  describe '.inherited' do
    it 'should initialize sub-task' do
      expect(@task.instance_var(:path)).to ending_with 'task_task.rb'
      expect(@task.instance_var(:name)).to eq :task
    end

    it 'should add to global object' do
      # since task class is unloaded after it is initialized, can't test again actual class name
      expect(@task.class.to_s).to eq 'New::TaskTask'
      expect(@task).to be_a New::Task
    end
  end

  describe '.get_task_name' do
    it 'should convert task path to symbolized task name' do
      expect(New::Task.send(:get_task_name, '/path/to/foo_bar_task.rb')).to eq :foo_bar
    end
  end

  describe '.validate_option' do
    it 'should validate required options' do
      expect(@task.validate_option(:required, 'foo')).to eq 'foo'

      expect{@task.validate_option(:required, nil)}.to raise_error
      expect{@task.validate_option(:required, '')}.to raise_error
      expect{@task.validate_option(:required, [])}.to raise_error
      expect{@task.validate_option(:required, {})}.to raise_error
    end

    it 'should validate default options' do
      expect(@task.validate_option(:default, nil)).to eq 'default value'
      expect(@task.validate_option(:default, '')).to eq 'default value'
      expect(@task.validate_option(:default, [])).to eq 'default value'
      expect(@task.validate_option(:default, {})).to eq 'default value'
      expect(@task.validate_option(:default, 'foo')).to eq 'foo'
    end

    it 'should validate strings' do
      expect(@task.validate_option(:type_string, 'foo_BAZ_bar')).to eq 'foo_BAZ_bar'

      expect{@task.validate_option(:type_string, 'bar_BAZ_foo')}.to raise_error
    end

    it 'should validate symbols' do
      expect(@task.validate_option(:type_symbol, 'foo_BAZ_bar')).to eq :foo_baz_bar

      expect{@task.validate_option(:type_symbol, 'bar_BAZ_foo')}.to raise_error
    end

    it 'should validate booleans' do
      expect(@task.validate_option(:type_boolean, 'true')).to eq true
      expect(@task.validate_option(:type_boolean, 'false')).to eq false

      expect{@task.validate_option(:type_boolean, 'foo')}.to raise_error
    end

    it 'should validate integers' do
      expect(@task.validate_option(:type_integer, '1')).to eq 1
      expect(@task.validate_option(:type_integer, '2.9')).to eq 2

      expect{@task.validate_option(:type_integer, '11')}.to raise_error
      expect{@task.validate_option(:type_integer, 'foo')}.to raise_error
    end

    it 'should validate floats' do
      expect(@task.validate_option(:type_float, '2')).to eq 2.0
      expect(@task.validate_option(:type_float, '2.9')).to eq 2.9

      expect{@task.validate_option(:type_float, '11')}.to raise_error
      expect{@task.validate_option(:type_float, 'foo')}.to raise_error
    end

    it 'should validate arrays' do
      expect(@task.validate_option(:type_array, ['foo'])).to eq [:foo]
      expect(@task.validate_option(:type_array, [nil, '', 'bar'])).to eq [:bar]

      expect{@task.validate_option(:type_array, [1])}.to raise_error
    end

    it 'should validate hashes with array of keys' do
      expect(@task.validate_option(:type_hash_array, { :foo => 'foo' })).to eq({ :foo => 'foo' })

      expect{@task.validate_option(:type_hash_array, { :bar => 'foo' })}.to raise_error
    end

    it 'should validate hashes with hash of keys/classes' do
      expect(@task.validate_option(:type_hash_hash, { :foo => '1' })).to eq({ :foo => 1 })

      expect{@task.validate_option(:type_hash_hash, { :foo => 'foo' })}.to raise_error
    end
  end

  describe '#bundle_install' do
    before do
      allow(@task).to receive(:system)
      @task.send :bundle_install
    end

    after do
      allow(@task).to receive(:system).and_call_original
    end

    it 'should run bundler with task Gemfile' do
      expect(@task).to have_received(:system).with starting_with 'bundle install --gemfile='
      expect(@task).to have_received(:system).with ending_with '/task/Gemfile'
    end
  end
end
