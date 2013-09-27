# ever used a pebble? Throw it in your code, and see where it goes.
# You can recover lost requirements (maybe). From Noel Rappin's testing legacy code
# http://assets.en.oreilly.com/1/event/59/Test%20Your%20Legacy%20Code%20Presentation.pdf
# https://speakerd.s3.amazonaws.com/presentations/4eb7fd5db029470051010f8b/legacy_ruby_midwest.pdf
class Pebble
  def initialize(name)
    @name = name
  end

  def method_missing(method_name, *args)
    p "#{@name}: #{method_name}(#{args.join(", ")}) from
       #{caller_method}"
    self
  end

  def caller_method(depth = 1)
    parse_caller(caller(depth+1).first).last
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file	= Regexp.last_match[1]
      line	= Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      [file, line, method]
    end
  end
end
