rspec dsl custom matcher in 1.3

# spec/support/matchers/start_with.rb
# Checks that the actual string starts with the expected
# Adapted from the Rails starts_with? method
# Use as "I would like to be matched".should start_with("I would like")
Spec::Matchers.define :start_with do |expected|
  match do |actual|
   # We compare the actual string up until the length of the expected "starts with" string
   actual.to_s[0..(expected.to_s.length - 1)] == expected.to_s
  end

  failure_message_for_should do |actual|
   "expected that \nACTUAL: #{actual} \nwould start with \nEXPECTED: #{expected}"
  end

  failure_message_for_should_not do |actual|
   "expected that \nACTUAL: #{actual} \nwould not start with \nEXPECTED: #{expected}"
  end

  description do
   "it starts with #{expected}"
  end
end