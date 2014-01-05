module New::Dsl
  # Replacement for `puts` that accepts various stylistic arguments
  # type:  =>  [symbol] Preset colors for [:fail, :success, :warn]
  # color:  => [integer] See docs for #colorize for color codes
  # justify: => [center|ljust|rjust] The type of justification to use
  # padding: => [integer] The maximum string size to justify text in
  #
  def say text = '', args = {}
    # Justify options
    if args[:justify] && args[:padding]
      text = text.send args[:justify], args[:padding]
    end

    # Type options
    # process last due to the addition of special color codes
    text = case args[:type]
    when :fail
      colorize text, 31
    when :success
      colorize text, 32
    when :warn
      colorize text, 33
    else
      colorize text, args[:color]
    end

    if args[:indent]
      text = (' ' * args[:indent]) + text
    end

    puts text
  end

private

  # Output text with a certain color (or style)
  # Reference for color codes
  # https://github.com/flori/term-ansicolor/blob/master/lib/term/ansicolor.rb
  #
  def colorize text, color_code
    return text unless color_code
    "\e[#{color_code}m#{text}\e[0m"
  end
end
