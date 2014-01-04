class New
  VERSION = '0.0.1'

  def self.templates
    templates_dir = File.expand_path '../../templates', __FILE__
    templates = Dir[File.join(templates_dir, '**')]
    templates.map{ |t| File.basename(t).to_sym }
  end
end

require 'new/cli'
require 'new/template'
