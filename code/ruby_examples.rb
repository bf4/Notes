class Attributor
  # defines Attributor.instance_methods
  # attr's are faster than define_method because they're only in C
  
  attr_reader :read
  # faster than def read; @read; end
  # you'll need to define the setter
  # is equivalent to attr :read
  attr_accessor :mini_read
  alias :mini_read? :mini_read
  
  
  attr_writer :write
  # faster than def write=(value); @write=value; end
  # you'll need to define the getter
  attr_accessor :access
  # faster than def access; @access; end, def access=(value);@access=value; end
  

  
  def read=(value)
    @read = "I had to define read to set: #{value}"
  end
  
  def write
    "I can return more than '#{@write}' in this getter"
  end
  
  def access
    "If I don't define the setter to access, it will still return '#{@access}'"
  end
  
  def mini_read=(value)
    @mini_read = "just and attr #{value}"
  end
end

a = Attributor.new
puts a.read
a.read = "foo"
puts a.read
puts a.write
a.write = "bar"
puts a.write
puts a.access
a.access ="yakety"
puts a.access
puts a.mini_read?
a.mini_read = "w00t"
puts a.mini_read?