require 'thor'

class New::Cli < Thor
  desc '[TEMPLATE]', "Create a new project with a given template (#{New.templates.join(' ')})"
  option :name, required: true
  def method_missing method, *args
    if New.templates.include? method.to_sym
      # Split args that look like options (i.e start with - or --) into a separate array
      positional_args, opts = Thor::Options.split args

      # Add all options here
      # Make sure to include required options up above as well so they show in the help menu
      parser = Thor::Options.new(
        name: Thor::Option.new(:name, required: true, type: :string)
      )

      # # The options hash is frozen in #initialize so you need to merge and re-assign
      self.options = options.merge(parser.parse(opts)).freeze

      # # Dispatch the command
      template method
    else
      super
    end
  end

  private

  def template template
    New::Template.new template, options
  end
end
