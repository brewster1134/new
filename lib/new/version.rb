module New::Version
  require 'semantic'

  def version= string
    @version ||= begin
      Semantic::Version.new string
    rescue
      New.say "#{string} is not a semantic version.  Use format `1.2.3`", type: :fail
      exit
    end
  end
  def version; @version; end

  def bump_version part
    case part
    when :major
      version.major += 1
    when :minor
      version.minor += 1
    when :patch
      version.patch += 1
    end

    version
  end

  def get_part
    New.say "              Current Version: #{version}", type: :success
    New.say "Specify which version to bump: [#{'Mmp'.green}] (#{'M'.green}ajor / #{'m'.green}inor / #{'p'.green}atch)"
    part = STDIN.gets.chomp!

    case part
    when 'M'
      :major
    when 'm'
      :minor
    when 'p'
      :patch
    end
  end
end
