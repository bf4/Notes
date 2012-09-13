
class MyEnumerable
  include Enumerable
  attr_reader :arr
  def initialize
    @arr = %w{this is an array of words}
  end
  def each(&block)
    arr.each(&block)
    #arr.each {|i| block.call(i)} # not as flexible
  end
  def <=>(other_object)
    self <=> other_object
  end
end


a = MyEnumerable.new

b = a.sort
b.each {|i| puts i}
flash[:notice]
flash[:warning]
flash[:new_user]
flash.discard
