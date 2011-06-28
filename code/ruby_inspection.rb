def print_class_with_method(klass,method)
  puts "\n\n\n*************printing #{klass} method #{method}"
  p constantize(klass).send(method.to_sym)
  puts "----------"
end
# File activesupport/lib/active_support/inflector.rb, line 278
def constantize(camel_cased_word)
  unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
    raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
  end

  Object.module_eval("::#{$1}", __FILE__, __LINE__)
end
#Module.constants (what's instantiated)
# also see
# http://snippets.dzone.com/posts/show/12065, and http://stackoverflow.com/questions/3488203/how-do-i-see-where-in-the-class-hierarchy-a-method-was-defined-and-overridden-in
# http://snippets.dzone.com/posts/show/2992
# http://stackoverflow.com/questions/1195531/listing-subclasses-doesnt-work-in-ruby-script-console
# http://matthewkwilliams.com/index.php/2008/08/22/rubys-objectspace-subclasses/
class Foo < String; end
print_class_with_method("Module", "constants")
print_class_with_method("Foo","singleton_methods")
print_class_with_method("Foo","public_methods") # Foo.methods
#Foo.method
print_class_with_method("Foo", "private_methods")
print_class_with_method("Foo","protected_methods")
f = Foo.new
print_class_with_method("Foo","ancestors")
@bar = "hiya"
# p "each object space String"
# count = ObjectSpace.each_object(String) {|x| p x}
# puts "total count: #{count}"
# p "each object space"
# count = ObjectSpace.each_object {|x| p x}
# puts "total count: #{count}"
print_class_with_method("Foo","global_variables")
print_class_with_method("Foo","instance_variables")
print_class_with_method("Foo","included_modules")
#kind_of? alias ?is_a?, like instance_of?
print_class_with_method("Module","protected")
#Module.public
#Module.private
#Module.remove_class_variable
#Module.module_function
#Module.remove_const
#Module.remove_method
#Module.undef_method
#Module.define_method
#Module.append_features
# Module.private_instance_methods
# Module.protected_instance_methods
# Module.public_class_method
# Module.private_class_method
# Module.public_instance_methods
# Module.instance_methods
# Module.included_modules
# Module.include? == true when other_mod is ancestor of mod IN mod.include?(other_mode)
# method_defined?
# Module.class_variables
# Module.ancestors
# Module.nesting
# Kernel.local_variables
# Kernel.global_variables
# Kernel.caller #returns teh current execution stack, array of strings
# Kernel.test(cmd, file1 <,file2>) -> obj #uses the integer cmd to perform various tests on file1, see table 27.9 on p 533
# Enumerable.partition, .grep, .all?, .any? .sort_by uses Schwartzian Transform p 457, .zip (huh?)
# Class.superclass
#Module.attr 
# attr :size, true === attr_accessor :size
# attr :size === attr_reader :size
#Module.alias_method can be used to retain access to overridden methods
# module Mod
#   alias_method :orig_exit, :exit
#   def exit(code=0)
#    puts "Exiting with code #{code}"
#    orig_exit(code)
#   end
# end
# include Mod
# exit(99)

  