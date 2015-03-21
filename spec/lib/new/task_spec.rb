describe New::Task do
  describe '.inherited' do
    before do
      # task fixture is already loaded in spec_helper
      @task = New::Task.tasks[:task]
    end

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
    before do
      @task = New::Task.new :validate_option, Dir.pwd
    end

    context 'with required options' do
      before do
        @task.instance_var :class_options, {
          :required => {
            :required => true
          }
        }
      end

      it 'should accept any value' do
        expect(@task.validate_option(:required, 'foo')).to eq 'foo'
      end

      it 'should reject missing values' do
        expect{@task.validate_option(:required, nil)}.to raise_error
        expect{@task.validate_option(:required, '')}.to raise_error
        expect{@task.validate_option(:required, [])}.to raise_error
        expect{@task.validate_option(:required, {})}.to raise_error
      end
    end

    context 'with defaulted options' do
      before do
        @task.instance_var :class_options, {
          :default => {
            :default => 'default value'
          }
        }
      end

      it 'should accept missing values' do
        expect(@task.validate_option(:default, nil)).to eq 'default value'
        expect(@task.validate_option(:default, '')).to eq 'default value'
        expect(@task.validate_option(:default, [])).to eq 'default value'
        expect(@task.validate_option(:default, {})).to eq 'default value'
      end

      it 'should accept user values' do
        expect(@task.validate_option(:default, 'foo')).to eq 'foo'
      end
    end

    context 'with strings' do
      before do
        @task.instance_var :class_options, {
          :type_string => {
            :validation => /foo_.+_bar/
          }
        }
      end

      it 'should accept regex matches' do
        expect(@task.validate_option(:type_string, 'foo_BAZ_bar')).to eq 'foo_BAZ_bar'
      end

      it 'should reject regex mismatches' do
        expect{@task.validate_option(:type_string, 'bar_BAZ_foo')}.to raise_error
      end
    end

    context 'with symbols' do
      before do
        @task.instance_var :class_options, {
          :type_symbol => {
            :type => Symbol,
            :validation => /foo_.+_bar/
          }
        }
      end

      it 'should accept regex matches' do
        expect(@task.validate_option(:type_symbol, 'foo_BAZ_bar')).to eq :foo_baz_bar
      end

      it 'should reject regex mismatches' do
        expect{@task.validate_option(:type_symbol, 'bar_BAZ_foo')}.to raise_error
      end
    end

    context 'with booleans' do
      before do
        @task.instance_var :class_options, {
          :type_boolean => {
            :type => Boolean
          }
        }
      end

      it 'should accept approved boolean keywords' do
        expect(@task.validate_option(:type_boolean, 'true')).to eq true
        expect(@task.validate_option(:type_boolean, 'Yes')).to eq true

        expect(@task.validate_option(:type_boolean, 'false')).to eq false
        expect(@task.validate_option(:type_boolean, 'No')).to eq false
      end

      it 'should reject non-approved keywords' do
        expect{@task.validate_option(:type_boolean, 'foo')}.to raise_error
      end
    end

    context 'with integers' do
      before do
        @task.instance_var :class_options, {
          :type_integer => {
            :type => Integer,
            :validation => (1..10)
          }
        }
      end

      it 'should accept numbers' do
        expect(@task.validate_option(:type_integer, '1')).to eq 1
        expect(@task.validate_option(:type_integer, '2.9')).to eq 2
      end

      it 'should reject out-of-range numbers' do
        expect{@task.validate_option(:type_integer, '11')}.to raise_error
      end

      it 'should reject non-numbers' do
        expect{@task.validate_option(:type_integer, 'foo')}.to raise_error
      end
    end

    context 'with floats' do
      before do
        @task.instance_var :class_options, {
          :type_float => {
            :type => Float,
            :validation => (0.5..10.5)
          }
        }
      end

      it 'should accept numbers' do
        expect(@task.validate_option(:type_float, '1')).to eq 1.0
        expect(@task.validate_option(:type_float, '2.9')).to eq 2.9
      end

      it 'should reject out-of-range numbers' do
        expect{@task.validate_option(:type_float, '11')}.to raise_error
      end

      it 'should reject non-numbers' do
        expect{@task.validate_option(:type_float, 'foo')}.to raise_error
      end
    end

    context 'with arrays' do
      context 'with type validation' do
        before do
          @task.instance_var :class_options, {
            :type_array => {
              :type => Array,
              :validation => Symbol
            }
          }
        end

        it 'should accept arrays with matchable types' do
          expect(@task.validate_option(:type_array, ['foo'])).to eq [:foo]
        end

        it 'should reject arrays with mismatched types' do
          expect{@task.validate_option(:type_array, [1])}.to raise_error
        end

        it 'should compact arrays' do
          expect(@task.validate_option(:type_array, ['', 'bar'])).to eq [:bar]
        end
      end

      context 'with array validation' do
        before do
          @task.instance_var :class_options, {
            :type_array_hash => {
              :type => Array,
              :validation => [:foo]
            }
          }
        end

        it 'should accept arrays with an object of matching keys' do
          expect(@task.validate_option(:type_array_hash, [{ :foo => 'foo' }])).to eq([{ :foo => 'foo' }])
        end

        it 'should reject arrays with an object without matching keys' do
          expect{@task.validate_option(:type_array_hash, [{ :bar => 'foo' }])}.to raise_error
        end
      end
    end

    context 'with hashes' do
      context 'with array validation' do
        before do
          @task.instance_var :class_options, {
            :type_hash_array => {
              :type => Hash,
              :validation => [:foo]
            }
          }
        end

        it 'should accept hashes with matching keys' do
          expect(@task.validate_option(:type_hash_array, { :foo => 'foo' })).to eq({ :foo => 'foo' })
        end

        it 'should reject hashes without matching keys' do
          expect{@task.validate_option(:type_hash_array, { :bar => 'foo' })}.to raise_error
        end
      end

      context 'with hash validation' do
        before do
          @task.instance_var :class_options, {
            :type_hash_hash => {
              :type => Hash,
              :validation => {
                :foo => Integer
              }
            }
          }
        end

        it 'should accept hashes with matching keys & types' do
          expect(@task.validate_option(:type_hash_hash, { :foo => '1' })).to eq({ :foo => 1 })
        end

        it 'should reject hashes without matching keys' do
          expect{@task.validate_option(:type_hash_hash, { :bar => '1' })}.to raise_error
        end

        it 'should reject hashes with matching keys but mismatched types' do
          expect{@task.validate_option(:type_hash_hash, { :foo => 'foo' })}.to raise_error
        end
      end
    end
  end
end
