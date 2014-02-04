module New::Dsl
  # Replacement for `puts` that accepts various stylistic arguments
  # https://github.com/fazibear/colorize/blob/master/lib/colorize.rb
  #
  # justify:  => [center|ljust|rjust] The type of justification to use
  # padding:  => [integer] The maximum string size to justify text in
  # color:    => [integer] See link above for supported colors
  # bgcolor:  => [integer] See link above for supported colors
  # type:     => [symbol] Preset colors for [:fail, :success, :warn]
  #
  def say text = '', args = {}
    # Justify options
    if args[:justify] && args[:padding]
      text = text.send args[:justify], args[:padding]
    end

    # Color text
    text = text.colorize(color: args[:color]) if args[:color]

    # Color background
    text = text.colorize(background: args[:bgcolor]) if args[:bgcolor]

    # Type options
    # process last due to the addition of special color codes
    text = case args[:type]
    when :fail
      text.red
    when :success
      text.green
    when :warn
      text.yellow
    else
      text
    end

    if args[:indent]
      text = (' ' * args[:indent]) + text
    end

    puts text
  end
end
