describe New do
  describe '.load_newfiles' do
    before do
      allow(New).to receive(:load_newfile)

      New.load_newfiles
    end

    after do
      allow(New).to receive(:load_newfile).and_call_original
    end

    it 'should load home Newfile' do
      expect(New).to have_received(:load_newfile).with(File.join(New::HOME_DIRECTORY, New::NEWFILE_NAME))
    end

    it 'should load project Newfile' do
      expect(New).to have_received(:load_newfile).with(File.join(Dir.pwd, New::NEWFILE_NAME))
    end
  end

  describe '.load_newfile' do
    before do
      allow(New).to receive(:new_object=)

      New.send :load_newfile, root('spec', 'fixtures', New::NEWFILE_NAME)
    end

    after do
      allow(New).to receive(:new_object=).and_call_original
    end

    it 'should load yaml Newfile as ruby hash' do
      expect(New).to have_received(:new_object=).with hash_including({ 'sources' => hash_including({ 'home_local' => '/home_local/source' })})
    end
  end

  describe '.new_object=' do
    before do
      New.class_var :new_object, {
        :foo => {
          :bar => 'baz'
        }
      }

      New.send :new_object=, {
        'foo' => {
          'bar' => 'foobar'
        }
      }
    end

    it 'should merge data into a symbolized hash' do
      expect(New.class_var(:new_object)).to eq({
        :foo => {
          :bar => 'foobar'
        }
      })
    end
  end
end
