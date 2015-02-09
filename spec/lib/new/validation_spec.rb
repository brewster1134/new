describe New::Validation do
  before do
    class ValidationSpec
      extend New::Validation
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
