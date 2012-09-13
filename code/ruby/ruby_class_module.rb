class Class
end
class Object
end

module Nodule
  OUTPUT = "Module"
  def super_klass_level
    OUTPUT
  end
  def module_level
    OUTPUT
  end
end
module Nodule2
  OUTPUT = "Module2"
  def super_klass_level
    OUTPUT
  end
end
class SuperKlass
  OUTPUT = "Super Class"
  def super_klass_level
    OUTPUT
  end
  def module_level
    OUTPUT
  end
  def klass_level
    OUTPUT
  end
end
class Klass < SuperKlass
  include Nodule
  include Nodule2
end

puts "Running #{Klass.new.super_klass_level}"
puts "Running #{Klass.new.module_level}"
puts "Running #{Klass.new.klass_level}"