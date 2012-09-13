def throw_foo
  puts "\nthrowing :foo"
  throw :foo
end
def raise_foo
  puts "\nraising foo"
  raise "foo"
end

begin
  raise_foo
rescue => e
  puts "rescued #{e.class}, #{e.message} #{caller[0]}"
end

begin
 puts "error is gone"
rescue => e
 puts "error persisted"
end

catch(:foo) do
  begin
    puts "\nthrowing in a catch(:foo) block"
    throw_foo
  rescue NameError, Exception => e
    puts "I don't get rescued #{e.class} #{e.message}"
  end
end

begin
  throw_foo
rescue Exception
  puts "rescued throw with NameError when not in a catch block"
end

puts "if I didn't catch :foo, I get a NameError, uncaught throw 'foo'"
#throw_foo

begin
  throw_foo
rescue Exception
  puts "rescuing an Exception won't catch a throw"
end

def michael(val)
  val%4 == 0
end
if michael(7)..michael(4)
  puts "something"
else
  puts 'something else'
end
@tries = 0
puts
puts
def raise_and_catch(val1,val2=nil)
  puts 'raise a standard error ' + $!.inspect
  raise StandardError if val1 == 1
  puts 'no global exception!'
  5
rescue StandardError
  puts $!.inspect
  puts 'clearning $!'
  $! = nil
  puts $!.inspect
  result = ""
  result = raise_and_catch(val2) unless val2.nil?
  puts 'we got a result ' + result.inspect
  6
end

result = raise_and_catch(1,2)
puts 'and we got ' + result.inspect