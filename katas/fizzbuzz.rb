=begin
  source: 
http://codingdojo.org/cgi-bin/wiki.pl?KataFizzBuzz
  instructions:
Write a program that prints the numbers from 1 to 100. But for multiples of three print "Fizz" instead of the number and for the multiples of five print "Buzz". For numbers which are multiples of both three and five print "FizzBuzz?".
=end

(1..100).each do |number|
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
