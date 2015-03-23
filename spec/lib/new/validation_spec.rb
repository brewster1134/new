describe New::Validation do
  before do
    class ValidationSpec
      extend New::Validation
    end
  end

  describe '.validate_option' do
    before do
      @task = New::Task.new :validate_option, Dir.pwd
    end

    context 'with required options' do
      before do
        @option = {
          :required => true
        }
      end

      it 'should accept any value' do
        expect(ValidationSpec.validate_option(:required, @option, 'foo')).to eq 'foo'
      end

      it 'should reject missing values' do
        expect{ValidationSpec.validate_option(:required, @option, nil)}.to raise_error
        expect{ValidationSpec.validate_option(:required, @option, '')}.to raise_error
        expect{ValidationSpec.validate_option(:required, @option, [])}.to raise_error
        expect{ValidationSpec.validate_option(:required, @option, {})}.to raise_error
      end
    end

    context 'with defaulted options' do
      before do
        @option = {
          :default => 'default value'
        }
      end

      it 'should accept missing values' do
        expect(ValidationSpec.validate_option(:default, @option, nil)).to eq 'default value'
        expect(ValidationSpec.validate_option(:default, @option, '')).to eq 'default value'
        expect(ValidationSpec.validate_option(:default, @option, [])).to eq 'default value'
        expect(ValidationSpec.validate_option(:default, @option, {})).to eq 'default value'
      end

      it 'should accept user values' do
        expect(ValidationSpec.validate_option(:default, @option, 'foo')).to eq 'foo'
      end
    end

    context 'with strings' do
      before do
        @option = {
          :validation => /foo_.+_bar/
        }
      end

      it 'should accept regex matches' do
        expect(ValidationSpec.validate_option(:type_string, @option, 'foo_BAZ_bar')).to eq 'foo_BAZ_bar'
      end

      it 'should reject regex mismatches' do
        expect{ValidationSpec.validate_option(:type_string, @option, 'bar_BAZ_foo')}.to raise_error
      end
    end

    context 'with symbols' do
      before do
        @option = {
          :type => Symbol,
          :validation => /foo_.+_bar/
        }
      end

      it 'should accept regex matches' do
        expect(ValidationSpec.validate_option(:type_symbol, @option, 'foo_BAZ_bar')).to eq :foo_baz_bar
      end

      it 'should reject regex mismatches' do
        expect{ValidationSpec.validate_option(:type_symbol, @option, 'bar_BAZ_foo')}.to raise_error
      end
    end

    context 'with booleans' do
      before do
        @option = {
          :type => Boolean
        }
      end

      it 'should accept approved boolean keywords' do
        expect(ValidationSpec.validate_option(:type_boolean, @option, 'true')).to eq true
        expect(ValidationSpec.validate_option(:type_boolean, @option, 'Yes')).to eq true

        expect(ValidationSpec.validate_option(:type_boolean, @option, 'false')).to eq false
        expect(ValidationSpec.validate_option(:type_boolean, @option, 'No')).to eq false
      end

      it 'should reject non-approved keywords' do
        expect{ValidationSpec.validate_option(:type_boolean, @option, 'foo')}.to raise_error
      end
    end

    context 'with integers' do
      before do
        @option = {
          :type => Integer,
          :validation => (1..10)
        }
      end

      it 'should accept numbers' do
        expect(ValidationSpec.validate_option(:type_integer, @option, '1')).to eq 1
        expect(ValidationSpec.validate_option(:type_integer, @option, '2.9')).to eq 2
      end

      it 'should reject out-of-range numbers' do
        expect{ValidationSpec.validate_option(:type_integer, @option, '11')}.to raise_error
      end

      it 'should reject non-numbers' do
        expect{ValidationSpec.validate_option(:type_integer, @option, 'foo')}.to raise_error
      end
    end

    context 'with floats' do
      before do
        @option = {
          :type => Float,
          :validation => (0.5..10.5)
        }
      end

      it 'should accept numbers' do
        expect(ValidationSpec.validate_option(:type_float, @option, '1')).to eq 1.0
        expect(ValidationSpec.validate_option(:type_float, @option, '2.9')).to eq 2.9
      end

      it 'should reject out-of-range numbers' do
        expect{ValidationSpec.validate_option(:type_float, @option, '11')}.to raise_error
      end

      it 'should reject non-numbers' do
        expect{ValidationSpec.validate_option(:type_float, @option, 'foo')}.to raise_error
      end
    end

    context 'with arrays' do
      context 'with type validation' do
        before do
          @option = {
            :type => Array,
            :validation => Symbol
          }
        end

        it 'should accept arrays with matchable types' do
          expect(ValidationSpec.validate_option(:type_array, @option, ['foo'])).to eq [:foo]
        end

        it 'should reject arrays with mismatched types' do
          expect{ValidationSpec.validate_option(:type_array, @option, [1])}.to raise_error
        end

        it 'should compact arrays' do
          expect(ValidationSpec.validate_option(:type_array, @option, ['', 'bar'])).to eq [:bar]
        end
      end

      context 'with array validation' do
        before do
          @option = {
            :type => Array,
            :validation => [:foo]
          }
        end

        it 'should accept arrays with an object of matching keys' do
          expect(ValidationSpec.validate_option(:type_array_hash, @option, [{ :foo => 'foo' }])).to eq([{ :foo => 'foo' }])
        end

        it 'should reject arrays with an object without matching keys' do
          expect{ValidationSpec.validate_option(:type_array_hash, @option, [{ :bar => 'foo' }])}.to raise_error
        end
      end
    end

    context 'with hashes' do
      context 'with array validation' do
        before do
          @option = {
            :type => Hash,
            :validation => [:foo]
          }
        end

        it 'should accept hashes with matching keys' do
          expect(ValidationSpec.validate_option(:type_hash_array, @option, { :foo => 'foo' })).to eq({ :foo => 'foo' })
        end

        it 'should reject hashes without matching keys' do
          expect{ValidationSpec.validate_option(:type_hash_array, @option, { :bar => 'foo' })}.to raise_error
        end
      end

      context 'with hash validation' do
        before do
          @option = {
            :type => Hash,
            :validation => {
              :foo => Integer
            }
          }
        end

        it 'should accept hashes with matching keys & types' do
          expect(ValidationSpec.validate_option(:type_hash_hash, @option, { :foo => '1' })).to eq({ :foo => 1 })
        end

        it 'should reject hashes without matching keys' do
          expect{ValidationSpec.validate_option(:type_hash_hash, @option, { :bar => '1' })}.to raise_error
        end

        it 'should reject hashes with matching keys but mismatched types' do
          expect{ValidationSpec.validate_option(:type_hash_hash, @option, { :foo => 'foo' })}.to raise_error
        end
      end
    end
  end

  describe '.validate_class' do
    it 'should validate String' do
      expect(ValidationSpec.validate_class(:foo, String)).to eq 'foo'
    end

    it 'should validate Symbol' do
      expect(ValidationSpec.validate_class('foo', Symbol)).to eq :foo
    end

    it 'should validate Boolean' do
      expect(ValidationSpec.validate_class('true', Boolean)).to eq true
    end

    it 'should validate Integer' do
      expect(ValidationSpec.validate_class('1', Integer)).to eq 1
    end

    it 'should validate Float' do
      expect(ValidationSpec.validate_class('1', Float)).to eq 1.0
    end

    it 'should validate Array' do
      expect(ValidationSpec.validate_class([1, nil, '', 2], Array)).to eq [1,2]
    end

    it 'should validate Hash' do
      expect(ValidationSpec.validate_class({ :one => 1, :two => nil, :three => '', :four => [], :five => 5 }, Hash)).to eq({ :one => 1, :five => 5 })
    end
  end
end
