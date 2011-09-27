# see http://stackoverflow.com/questions/516579/is-there-a-way-to-get-a-collection-of-all-the-models-in-your-rails-app
puts "presuming BaseModel is the model whose subclasses you're after"
puts "we require those files"
puts "and we want a list of those models that match our desired pattern"
puts "so now we can act on that model and be sure it is loaded"
def get_subclasses_of_base_model
  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
  Object.subclasses_of(BaseModel)
end

def get_list_of_models
  get_subclasses_of_base_model.map do |model|
    model.name if model.name.match(/DesiredModel/)
  end
end
