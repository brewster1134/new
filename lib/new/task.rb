class New::Task
  attr_accessor :description

  def initialize path
    @path = File.expand_path path
  end
end
