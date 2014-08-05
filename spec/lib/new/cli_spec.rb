require 'spec_helper'

describe New::Cli do
  describe '#templates' do
    it 'should list available templates' do
    end
  end

  describe '#init' do
    it 'should create a .new configuration file' do
    end
  end

  describe '#project' do
    it 'should create a new directory for the project' do
    end

    it 'should create interpolated assets' do
    end
  end

  describe '#release' do
    it 'should call run for the listed tasks' do
    end
  end

  describe '#version' do
    it 'should return the current version of the new gem' do
    end
  end
end



#   describe '#projects' do
#     before do
#       allow(New).to receive(:templates).and_return([:foo])
#       allow(subject).to receive(:project)
#     end

#     after do
#       allow(New).to receive(:templates).and_call_original
#       allow(subject).to receive(:project).and_call_original
#     end

#     it 'should accept template name as argument' do
#       expect { subject.foo 'party' }.to_not raise_error
#     end

#     it 'should raise an error if no name is given' do
#       expect { subject.foo }.to raise_error
#     end

#     it 'should raise an error for non-template argument' do
#       expect { subject.bar }.to raise_error
#     end
#   end

#   describe '#init' do
#     before do
#       stub_const 'New::CUSTOM_DIR', root('.tmp', '.new')
#       subject.init
#     end

#     after :all do
#       FileUtils.rm_r root('.tmp', '.new')
#     end

#     it 'should create .new dir' do
#       expect(Dir.exists?(root('.tmp', '.new'))).to eq true
#     end

#     it 'should create .new file' do
#       expect(File.exists?(root('.tmp', '.new', New::CONFIG_FILE))).to eq true

#       # Check that the keys are properly formatted in the yaml file
#       expect(File.read(root('.tmp', '.new', New::CONFIG_FILE))).to match /^version: 0.0.0$/
#     end

#     it 'should create an empty templates & tasks dir' do
#       expect(Dir.exists?(root('.tmp', '.new', 'templates'))).to eq true
#       expect(Dir.exists?(root('.tmp', '.new', 'tasks'))).to eq true
#     end
#   end

#   describe '#release' do
#     context 'for an invalid project' do
#       before do
#         Dir.chdir root('.tmp')
#         File.delete '.new' rescue nil
#       end

#       it 'should raise an error if no config file is found' do
#         expect { subject.release }.to raise_error
#       end
#     end

#     context 'for a valid project' do
#       before do
#         Dir.chdir root('spec', 'fixtures', 'project')
#       end

#       # test that the task is required
#       describe 'require' do
#         before do
#           allow(New::Task).to receive :inherited
#           subject.release
#         end

#         after do
#           allow(New::Task).to receive(:inherited).and_call_original
#         end

#         it 'should require the task' do
#           expect(New::Task).to have_received(:inherited).with(New::Task::FooTask).once
#         end
#       end

#       # test that the task is initialized
#       describe 'initialize' do
#         before do
#           require root('spec', 'fixtures', 'custom', 'tasks', 'custom_bar_task', 'custom_bar_task')
#           allow(New::Task::CustomBarTask).to receive :new
#           stub_const 'New::CONFIG_FILE', '.new_cli_release_spec'
#           subject.release
#         end

#         after do
#           allow(New::Task::CustomBarTask).to receive(:new).and_call_original
#         end

#         it 'should initialize the task' do
#           expect(New::Task::CustomBarTask).to have_received(:new).with({ tasks: { custom_bar_task: nil }})
#         end
#       end
#     end
#   end
# end
