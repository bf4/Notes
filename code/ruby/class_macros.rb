class MacroTest

  def self.set_help_me(msg)
    @msg = msg
    def self.help_me
      @msg
    end

  end
  set_help_me "Benjamin"
  
end
class MacroSub < MacroTest
  set_help_me "Geronimo"
end

puts MacroTest.help_me
#puts MacroTest.instance_variable_get('@name')
puts MacroSub.help_me
#puts MacroSub.instance_variable_get('@name')