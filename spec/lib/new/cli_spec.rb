require 'tmpdir'

describe New::Cli do
  before do
    # run all cli commands from a tmp project directory
    @pwd = Dir.pwd
    FileUtils.chdir New::PROJECT_DIRECTORY

    # initialize cli instance
    @cli = New::Cli.new

    # proc to load the proejct newfile
    @project_newfile = -> { File.read(File.join(New::PROJECT_DIRECTORY, New::NEWFILE_NAME)) }
  end

  after do
    # # change back to root for the rest of the tests
    FileUtils.chdir @pwd
  end

  describe '#init' do
    before do
      @task = New::Task.tasks[:task]

      stub_const 'New::NEWFILE_NAME', 'Newfile_spec'
      allow(A).to receive(:sk).and_yield 'foo'
      allow(New::Task).to receive(:validate_option).and_return 'foo'
      allow(@task).to receive(:class_options).and_return({:foo => {}})

      @cli.options = {
        'name' => 'Foo Name',
        'version' => '1.2.3',
        'tasks' => ['spec#task']
      }

      @cli.init
      @pn = @project_newfile[]
    end

    after do
      FileUtils.rm File.join(New::PROJECT_DIRECTORY, New::NEWFILE_NAME)
      stub_const 'New::NEWFILE_NAME', 'Newfile'
      allow(New::Task).to receive(:validate_option).and_call_original
      allow(@task).to receive(:class_options).and_call_original
    end

    it 'should write to the project Newfile' do
      expect(@pn).to include 'name: Foo Name'
      expect(@pn).to include 'version: 1.2.3'
      expect(@pn).to include "tasks:\n  task:\n    foo: foo"
    end
  end

  describe '#tasks' do
    before do
      @cli.tasks :show_source => false
    end

    it 'should request to load newfiles and sources' do
      expect(New).to have_received(:load_newfiles).ordered
      expect(New::Source).to have_received(:load_sources).ordered
    end

    it 'should list all available tasks' do
      expect(S).to have_received(:ay).with('spec', anything).ordered
      expect(S).to have_received(:ay).with(including('/spec/fixtures'), anything).ordered
      expect(S).to have_received(:ay).with('task', anything).ordered
      expect(S).to have_received(:ay).with('Spec Task Description', anything).ordered
    end
  end

  describe '#release' do
    before do
      allow(@cli).to receive(:get_changelog_from_user).and_return(['changelog'])
      allow(New).to receive(:new)

      @cli.options = { 'skip' => [] }

      New.new_object = {
        :version => '1.2.3'
      }
    end

    after do
      allow(New).to receive(:new).and_call_original
    end

    context 'when bumping any version' do
      before do
        allow(A).to receive(:sk).and_yield 'p'

        @cli.release
      end

      it 'should set the cli flag' do
        expect(New.class_var(:cli)).to eq true
      end

      it 'should load Newfiles and sources once' do
        expect(New).to have_received(:load_newfiles).once
      end

      it 'should initialize' do
        expect(New).to have_received(:new).with '1.2.4', ['changelog'], []
      end
    end

    context 'when bumping a patch version' do
      before do
        allow(A).to receive(:sk).and_yield 'p'

        @cli.release
      end

      it 'should increment the patch version' do
        expect(New).to have_received(:new).with '1.2.4', ['changelog'], []
      end
    end

    context 'when bumping a minor version' do
      before do
        allow(A).to receive(:sk).and_yield 'm'

        @cli.release
      end

      it 'should increment the minor version and set the patch version to 0' do
        expect(New).to have_received(:new).with '1.3.0', ['changelog'], []
      end
    end

    context 'when bumping a major version' do
      before do
        allow(A).to receive(:sk).and_yield 'M'

        @cli.release
      end

      it 'should increment the major version and set the minor & patch versions to 0' do
        expect(New).to have_received(:new).with '2.0.0', ['changelog'], []
      end
    end
  end

  describe '#version' do
    before do
      New.class_var :new_object, {
        :name => 'Project Name',
        :version => '1.2.3'
      }
    end

    it 'should return the current version' do
      @cli.version

      expect(S).to have_received(:ay).with 'Project Name', anything
      expect(S).to have_received(:ay).with '1.2.3', anything
    end
  end

  describe '#test' do
    before do
      dbl = double
      allow(dbl).to receive(:start)
      allow(Kernel).to receive(:system)
      allow(Kernel).to receive(:sleep)
      allow(Listen).to receive(:to).and_return dbl
      allow(New).to receive(:load_newfiles)

      New.class_var :new_object, {
        :sources => {
          :default => root('spec', 'fixtures')
        }
      }

      @cli.options = {
        'watch' => true
      }

      @cli.test
    end

    after do
      allow(Kernel).to receive(:system).and_call_original
      allow(Kernel).to receive(:sleep).and_call_original
      allow(Listen).to receive(:to).and_call_original
      allow(New).to receive(:load_newfiles).and_call_original
    end

    it 'should run rspec with task paths' do
      expect(Listen).to have_received(:to).with root('spec', 'fixtures', 'source', 'task'), root('spec', 'fixtures', 'source', 'task_two')
    end
  end

  describe '#get_array_from_user' do
    before do
      allow(@cli).to receive(:get_hash_from_user)
    end

    after do
      allow(@cli).to receive(:get_hash_from_user).and_call_original
    end

    it 'should prompt for valid values' do
      responses = ['foo', 'bar', '']
      allow(A).to receive(:sk) do |text, options, &block|
        block.call responses.shift
      end

      user_array = @cli.get_array_from_user
      expect(user_array).to eq(['foo', 'bar'])
    end

    it 'should accept a data type' do
      responses = ['foo', '1', 'bar', '2', '']
      allow(A).to receive(:sk) do |text, options, &block|
        block.call responses.shift
      end

      user_array = @cli.get_array_from_user Integer
      expect(user_array).to eq([1, 2])
    end

    it 'should accept an array' do
      allow(@cli).to receive(:get_hash_from_user).and_return({ :foo => 'foo1', :bar => 'bar1' }, { :foo => 'foo2', :bar => 'bar2' })

      responses = ['y', 'y', 'n']
      allow(A).to receive(:sk) do |text, options, &block|
        block.call responses.shift
      end

      user_array = @cli.get_array_from_user [:foo, :bar]
      expect(user_array).to eq([
        { :foo => 'foo1', :bar => 'bar1' },
        { :foo => 'foo2', :bar => 'bar2' }
      ])
    end

    it 'should accept a hash' do
      allow(@cli).to receive(:get_hash_from_user).and_return({ :foo => 1, :bar => true }, { :foo => 2, :bar => false })

      responses = ['y', 'y', 'n']
      allow(A).to receive(:sk) do |text, options, &block|
        block.call responses.shift
      end

      user_array = @cli.get_array_from_user({
        :foo => Integer,
        :bar => Boolean
      })
      expect(user_array).to eq([
        { :foo => 1, :bar => true },
        { :foo => 2, :bar => false }
      ])
    end
  end

  describe '#get_hash_from_user' do
    context 'with array validation' do
      it 'should prompt for valid values' do
        responses = ['FOO', 'BAR', '']
        allow(A).to receive(:sk) do |text, options, &block|
          block.call responses.shift
        end

        user_hash = @cli.get_hash_from_user([:foo, :bar])
        expect(user_hash).to eq({
          :foo => 'FOO',
          :bar => 'BAR'
        })
      end
    end

    context 'with hash validation' do
      it 'should prompt for valid values' do
        responses = ['FOO', '1', 'BAR', 'true', '']
        allow(A).to receive(:sk) do |text, options, &block|
          block.call responses.shift
        end

        user_hash = @cli.get_hash_from_user({
          :foo => Integer,
          :bar => Boolean
        })

        expect(user_hash).to eq({
          :foo => 1,
          :bar => true
        })
      end
    end

    context 'with user specified key/values' do
      it 'should prompt for valid values' do
        responses = ['foo', 'FOO', 'bar', 'BAR', '']
        allow(A).to receive(:sk) do |text, options, &block|
          block.call responses.shift
        end

        user_hash = @cli.get_hash_from_user

        expect(user_hash).to eq({
          :foo => 'FOO',
          :bar => 'BAR'
        })
      end
    end
  end
end
