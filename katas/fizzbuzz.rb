=begin
  source:
http://codingdojo.org/cgi-bin/wiki.pl?KataFizzBuzz
  instructions:
Write a program that prints the numbers from 1 to 100. But for multiples of three print "Fizz" instead of the number and for the multiples of five print "Buzz". For numbers which are multiples of both three and five print "FizzBuzz?".
=end

class Solutions
  class << self
    def run(solution)
      method(solution.to_sym).call
    end
    def solutions
      public_methods(false).select {|name| name =~ /solution$/ }
    end
    def basic_crappy_solution
      numbers do |number|
        just_the_number = true
        if number % 3 == 0
          print 'Fizz'
          just_the_number = false
        end
        if number % 5 == 0
          print 'Buzz'
          just_the_number = false
        end
        if just_the_number
          print number
        end
        puts
      end
    end

    def numbers(&block)
      (0..100).each do |number|
        yield number
      end
    end
  end
end
if __FILE__ == $0
  if ARGV.empty?
    puts "usage: ruby solutions.rb [solution name]"
    puts "available names are: #{Solutions.solutions.join(", ")}"
  else
    Solutions.run ARGV[0]
  end
end
