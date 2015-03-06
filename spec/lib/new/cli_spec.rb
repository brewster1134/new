require 'tmpdir'

describe New::Cli do
  before do
    # run all cli commands from a tmp project directory
    @pwd = FileUtils.pwd
    FileUtils.chdir New::PROJECT_DIRECTORY

    # initialize cli instance
    @cli = New::Cli.new

    # get initialized spec task
    @task = New::Task.tasks[:task]

    # proc to load the proejct newfile
    @project_newfile = -> { File.read(File.join(New::PROJECT_DIRECTORY, New::NEWFILE_NAME)) }
  end

  after do
    # # change back to root for the rest of the tests
    FileUtils.chdir @pwd
  end

  describe '#init' do
    before do
      stub_const 'New::NEWFILE_NAME', 'Newfile_spec'

      @cli.options = {
        'name' => 'Foo Name',
        'version' => '1.2.3',
        'tasks' => ['spec#task']
      }
    end

    after do
      FileUtils.rm File.join(New::PROJECT_DIRECTORY, New::NEWFILE_NAME)
      stub_const 'New::NEWFILE_NAME', 'Newfile'
    end

    it 'should write the name and version' do
      New::Task.tasks[:task].instance_var :options, {}
      @cli.init
      pn = @project_newfile[]

      expect(pn).to include 'name: Foo Name'
      expect(pn).to include 'version: 1.2.3'
    end

    context 'with array option' do
      it 'should ask for multiple array values' do
        responses = ['1', 'foo', '2', '']
        allow(A).to receive(:sk) do |text, options, &block|
          block.call responses.shift
        end

        New::Task.tasks[:task].instance_var :options, {
          :array => {
            :description => 'Array',
            :type => Array,
            :validation => Integer
          }
        }
        @cli.init
        pn = @project_newfile[]

        expect(pn).to include "tasks:\n  task:\n    array:\n    - 1\n    - 2"
      end

      context 'when required' do
        it 'should not allow an empty array' do
          responses = ['', 'foo', '']
          allow(A).to receive(:sk) do |text, &block|
            block.call responses.shift
          end

          New::Task.tasks[:task].instance_var :options, {
            :array => {
              :description => 'Array',
              :required => true,
              :type => Array
            }
          }
          @cli.init
          pn = @project_newfile[]

          expect(pn).to include "tasks:\n  task:\n    array:\n    - foo"
        end
      end

      context 'when not required' do
        it 'should allow an empty array' do
          allow(A).to receive(:sk).and_yield('')
          New::Task.tasks[:task].instance_var :options, {
            :array => {
              :description => 'Array',
              :required => false,
              :type => Array
            }
          }
          @cli.init
          pn = @project_newfile[]

          expect(pn).to include "tasks:\n  task:\n    array: []"
        end
      end
    end

    context 'with hash option' do
      it 'should ask for keys and values' do
        responses = ['foo', 'FOO', 'bar', 'BAR', '']
        allow(A).to receive(:sk) do |text, options, &block|
          block.call responses.shift
        end

        New::Task.tasks[:task].instance_var :options, {
          :hash => {
            :description => 'Hash',
            :type => Hash
          }
        }
        @cli.init
        pn = @project_newfile[]

        expect(pn).to include "tasks:\n  task:\n    hash:\n      foo: FOO\n      bar: BAR"
      end

      context 'with array validation' do
        it 'should ask for multiple hash values' do
          responses = ['FOO', 'BAR', '']
          allow(A).to receive(:sk) do |text, options, &block|
            block.call responses.shift
          end

          New::Task.tasks[:task].instance_var :options, {
            :hash => {
              :description => 'Hash',
              :type => Hash,
              :validation => [:foo, :bar]
            }
          }
          @cli.init
          pn = @project_newfile[]

          expect(pn).to include "tasks:\n  task:\n    hash:\n      foo: FOO\n      bar: BAR"
        end
      end

      context 'with hash validation' do
        it 'should ask for multiple hash values' do
          responses = ['FOO', '1', 'BAR', '2', '']
          allow(A).to receive(:sk) do |text, options, &block|
            block.call responses.shift
          end

          New::Task.tasks[:task].instance_var :options, {
            :hash => {
              :description => 'Hash',
              :type => Hash,
              :validation => {
                :foo => Integer,
                :bar => Integer
              }
            }
          }
          @cli.init
          pn = @project_newfile[]

          expect(pn).to include "tasks:\n  task:\n    hash:\n      foo: 1\n      bar: 2"
        end
      end
    end
  end

  describe '#tasks' do
    before do
      @cli.tasks
    end

    it 'should request to load newfiles and sources' do
      expect(New).to have_received(:load_newfiles).ordered
      expect(New::Source).to have_received(:load_sources).ordered
    end

    it 'should list all available tasks' do
      expect(S).to have_received(:ay).with('spec', anything).ordered
      expect(S).to have_received(:ay).with(including('/spec/fixtures'), anything).ordered
      expect(S).to have_received(:ay).with('task', anything).ordered
      expect(S).to have_received(:ay).with('Spec Task Description').ordered
    end
  end

  describe '#release' do
    before do
      allow(New).to receive(:new)

      New.new_object = {
        :version => '1.2.3'
      }
    end

    after do
      allow(New).to receive(:new).and_call_original
    end

    context 'when bumping any version' do
      before do
        allow(A).to receive(:sk).and_yield('p')
        @cli.release
      end

      it 'should set the cli flag' do
        expect(New.class_var(:cli)).to eq true
      end

      it 'should load Newfiles and sources once' do
        expect(New).to have_received(:load_newfiles).once
      end

      it 'should initialize' do
        expect(New).to have_received(:new).with '1.2.4'
      end
    end

    context 'when bumping a patch version' do
      before do
        allow(A).to receive(:sk).and_yield('p')
        @cli.release
      end

      it 'should increment the patch version' do
        expect(New).to have_received(:new).with '1.2.4'
      end
    end

    context 'when bumping a minor version' do
      before do
        allow(A).to receive(:sk).and_yield('m')
        @cli.release
      end

      it 'should increment the minor version and set the patch version to 0' do
        expect(New).to have_received(:new).with '1.3.0'
      end
    end

    context 'when bumping a major version' do
      before do
        allow(A).to receive(:sk).and_yield('M')
        @cli.release
      end

      it 'should increment the major version and set the minor & patch versions to 0' do
        expect(New).to have_received(:new).with '2.0.0'
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
      expect(Listen).to have_received(:to).with root('spec', 'fixtures', 'source', 'task')
    end
  end
end
