#---
# Excerpted from "Programming Ruby 1.9 and 2.0",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/ruby4 for more book information.
#---
require 'logger'
module TraceCalls
  @@logger = Logger.new('calls.log')
  @@logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
  end
  @@pwd = Dir.pwd.to_s
  @@methods = {}
  END { p @methods }
  def self.included(klass)
    klass.instance_methods(false).each do |existing_method|
      wrap(klass, existing_method)
    end
    def klass.method_added(method)  # note: nested definition
      unless @trace_calls_internal
        @trace_calls_internal = true
        TraceCalls.wrap(self, method)
        @trace_calls_internal = false
      end
    end
  end

  def self.wrap(klass, method)
    klass.instance_eval do
      method_object = instance_method(method)
      # @@methods[method_object.source_location.inspect] =  false
      file, line = method_object.source_location
      if file.to_s.include?(@@pwd)
        file = file.sub(@@pwd, '')
        method_name = [file,method.to_s,line.to_s].join('_')
        @@methods[method_name] = false
        @@logger.info "--- Wrapping #{klass.name}::#{method} #{method_object.source_location}"
        define_method(method) do |*args, &block|
          @@methods[method_name] = true
          # @@methods[method_object.source_location.inspect] =  true
          @@logger.info "==> calling #{method} at #{file}:#{line} with #{args.inspect}"
          result = method_object.bind(self).call(*args, &block)
          # @@logger.info "<== #{method} returned #{result.inspect}"
          result
        end
      end
    end
  end
end
include TraceCalls
