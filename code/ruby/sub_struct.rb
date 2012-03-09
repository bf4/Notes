require 'ostruct'
class SuperDuper
  attr_accessor :foo, :bar, :baz
end
class MethodsMock
  # optionally specify a parent
  def self.from_class(klass,parent_klass=nil)
    if parent_klass
      meths = []
      (klass.ancestors - parent_klass.ancestors[1..-1]).each do |a|
        meths.concat(a.instance_methods(false))
      end
    else
      meths = klass.instance_methods(false)
    end
    methods_to_open_struct(meths)
  end
  private
  def self.build_methods_hash(meths)
    hash = {}
    meths.each {|m| hash[m.to_sym] = nil }
    hash
  end

  def self.methods_to_open_struct(meths)
    OpenStruct.new(build_methods_hash(meths))
  end

end
o = MethodsMock.from_class(SuperDuper)
puts o.methods(false).inspect
puts o.respond_to?(:foo)
puts o.respond_to?(:nope)
puts SuperDuper.ancestors

# def build_methods_hash(meths)
#   hash = {}
#   meths.each {|m| hash[m.to_sym] = nil }
#   hash
# end
# inst_meths = SuperDuper.instance_methods(false)
# 
# def methods_to_open_struct(meths)
#   OpenStruct.new(build_methods_hash(meths))
# end
# 
# os = methods_to_open_struct(inst_meths)
# 
# puts os.methods(false).inspect
# 
# puts os.respond_to?(:foo)
# puts os.respond_to?(:nope)
















