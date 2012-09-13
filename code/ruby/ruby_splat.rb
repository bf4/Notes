class Foo
  def composite_method_with_splat(arg1, arg2 = 0, *splat)
    puts "composite method splat received is #{splat.inspect}"
    args = [arg1, arg2]
    # crazy splat. if not passed in, will be an empty array []
    # an empty array is an object, so if passed as an argument, will become [[]]
    # because a splat in a method call is automatically expanded by ruby
    # we convert all the received arguments into one array and send that
    # in the method call as a splat, in order to preserve the number of arguments
    args.concat(splat) unless splat.size == 0
    one = method1_with_splat(*args)
    if one
      one
    else
      method2_with_splat(*args)
    end
  end
  
  def composite_method_without_splat_fix(arg1, arg2 = 0, *splat)
    puts "composite method splat received is #{splat.inspect}"
    one = method1_with_splat(arg1, arg2, splat)
    if one
      one
    else
      method2_with_splat(arg1, arg2, splat)
    end
  end
  def method1_with_splat(arg1, arg2 = 0, *splat)
    puts "method1 splat received is #{splat.inspect}"
    [arg1, arg2, splat] if arg1 == 1
  end
  def method2_with_splat(arg1, arg2 = 0, *splat)
    puts "method2 splat received is #{splat.inspect}"
    [arg1, arg2, splat]
  end
end

foo = Foo.new
puts "\n\ncomposite call method 1"
puts "#{foo.composite_method_with_splat(1).inspect}"
puts "\n\ncomposite call method 2"
puts "#{foo.composite_method_with_splat(2).inspect}"
puts "\n\ncomposite call method 1 with extra args (splat)"
puts "#{foo.composite_method_with_splat(1,2,3,4).inspect}"
puts "\n\ncomposite call method 1 with extra args (splat), and no splat fix"
puts "#{foo.composite_method_without_splat_fix(1,2,3,4).inspect}"
puts "\n\nmethod 1 called directly with extra args (splat), for comparison"
puts "#{foo.method1_with_splat(1,2,3,4).inspect}"