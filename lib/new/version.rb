module New::Version
  require 'semantic'

  def part; @part; end
  def previous_version; @previous_version; end
  def version; @version; end

  def bump_version previous_version, part = nil
    @previous_version = get_version previous_version
    @part = part ||= get_part

    # bump version
    case part
    when :major
      @previous_version.major += 1
      @previous_version.minor = 0
      @previous_version.patch = 0
    when :minor
      @previous_version.minor += 1
      @previous_version.patch = 0
    when :patch
      @previous_version.patch += 1
    end

    # set new version
    @version = @previous_version
  end

private

  def get_part
    New.say "            Current Version: #{previous_version}", type: :success
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

  def get_version version
    begin
      Semantic::Version.new version.to_s
    rescue
      New.say "#{version} is not a semantic version.  Use format `1.2.3`", type: :fail
      exit
    end
  end
end
