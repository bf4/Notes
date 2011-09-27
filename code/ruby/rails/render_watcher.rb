# put in config/initializers/render_watcher.rb
# tail -f log/development.log | grep 'RENDERED'

# shows the rendered action for each call
# this class may not work right, so you may want to comment it out
class ActionController::Base
  alias_method :original_render, :render
    
  def remove_unwanted_keys(options)
    options.delete(:locals) #hard to read otherwise
    options.inspect
  end
  
  def render(options = nil, extra_options = {}, &block) #:doc:
    options_to_display = options.dup # so we don't remove the local from the call!
    Rails.logger.debug "ACTION RENDERED #{remove_unwanted_keys(options_to_display)}"
    original_render(options, extra_options, &block)
  end
end

# shows every partial called
class ActionView::PartialTemplate
  alias_method :original_initialize, :initialize
  def initialize(view, partial_path, object = nil, locals = {})
    Rails.logger.debug "PARTIAL RENDERED #{extract_partial_name_and_path(view, partial_path).inspect}"
    original_initialize(view, partial_path, object, locals)
  end
end
