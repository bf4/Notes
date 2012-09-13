# by Chris Hunt in rubyparley
Person = Class.new do
  def talk
    'hello'
  end
end

#Same with a struct (and probably more useful):

Person = Struct.new(:first_name, :last_name) do
  def name
    "#{first_name} #{last_name}"
  end
end
