class New
  VERSION = '0.0.1'
  TEMPLATES_DIR = File.expand_path('../../templates', __FILE__)

  # List all the available templates
  #
  def self.templates
    templates = Dir[File.join(TEMPLATES_DIR, '**')]
    templates.map{ |t| File.basename(t).to_sym }
  end
end

require 'new/cli'
require 'new/dsl'
require 'new/objects'
require 'new/task'
require 'new/template'

class New
  extend New::Dsl
end
