class Funk
  class << self
    attr_accessor :groove
  end
  
  # instance var set at instance level
  def initialize(g)
    @groove = g
  end
  # instance var set at class level  
  def self.set_groove(g)
    @groove = g
  end
end
puts "Groove #{Funk.groove}"
Funk.groove = "foo"
puts "Groove #{Funk.groove}"
Funk.set_groove("bar")
puts "Groove #{Funk.groove}"
#Funk.stub!(:groove).and_return("baz")
f = Funk.new("baz")
puts "Groove #{Funk.groove}"