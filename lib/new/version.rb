module New::Version
  require 'semantic'

  def version; @version; end

  def get_part
    New.say "            Current Version: #{version}", type: :success
    New.say " Specify which part to bump: [#{'Mmp'.green}] (#{'M'.green}ajor / #{'m'.green}inor / #{'p'.green}atch)"
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

  def bump_version current_version, part
    get_version current_version

    case part
    when :major
      version.major += 1
      version.minor = 0
      version.patch = 0
    when :minor
      version.minor += 1
      version.patch = 0
    when :patch
      version.patch += 1
    end

    version
  end

private

  def get_version string
    @version ||= begin
      Semantic::Version.new string
    rescue
      New.say "#{string} is not a semantic version.  Use format `1.2.3`", type: :fail
      exit
    end
  end
end
