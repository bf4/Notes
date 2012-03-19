require 'rubygems'
require 'haml'
require "haml/html"
# require 'ruby-debug' 19
# require 'ruby_parser'
# require 'hpricot'
# require 'erubis'
# files.each do |file|
#   `html2haml -rx #{file} #{file.gsub(/\.(erb|rhtml)$/, '.haml')}`
# end
class ErbToHaml
  attr_reader :files, :new_files, :errors, :results
  def initialize
    @files = get_files
    @new_files = []
    @errors = {:haml => [], :haml_error_files => [], :standard => [], :none => [], :duplicate => []}
    @results = {:success => [], :failure => [] }
    convert_files
    puts errors[:haml].uniq.inspect
    puts errors[:standard].uniq.inspect
    puts
    puts results.map {|k,v| "#{k}: #{v.size}"}.inspect
  end
  def get_files
    Dir['**/*.{rhtml,erb}']
  end
  def convert_files
    files.each do |file|
      convert_file(file)
    end
  end
  def convert_file(file)
    new_file = new_file_name(file)
    new_files << new_file
    html = read_file(file)
    puts "**** converting #{file} to #{new_file}"
    render_html_to_haml(html) do |haml|
      process_haml(haml, file, new_file)
    end
  end
  def render_html_to_haml(html)
    begin
      haml = Haml::HTML.new(html, :erb => true, :xhtml => true).render
      yield haml if block_given?
    rescue => e
      puts "ACK conversion failed #{e.class}, #{e.message}, #{caller[0]}"
    end
  end
  def process_haml(haml, file, new_file)
    if valid_haml?(haml, new_file) && !duplicate_haml?(new_file)
      puts 'saving file'
      # zero out length of file
      File.open(file,'w+') do |f|
        f.write(haml) # possible race condition..
        # `git mv #{file} #{new_file} && haml #{new_file}`
        errors[:none] << new_file
        results[:success] << new_file
      end
      # sleep(0.5)
      `git mv #{file} #{new_file}`
    end
  end
  def duplicate_haml?(new_file)
    if File.exists?(new_file)
      puts "WHOA, that file already exists"
      errors[:duplicate] << new_file
      true
    else
      false
    end
  end
  def valid_haml?(haml, new_file)
    validated = false
    if haml.size == 0
      message = "ACK zero length!"
      results[:failure] << new_file
      puts message
    elsif haml =~ /<%|%>/m
      message = "ACK erb <% %> tags leftover. something went wrong"
      results[:failure] << new_file
      puts message
    else
      validated = test_haml_compile(haml,new_file)
    end
    validated
  end
  def test_haml_compile(haml,new_file)
    begin
      result = Haml::Engine.new(haml)
      validated = true
    rescue Haml::SyntaxError => e
      message = "haml syntax error #{e.class} #{e.message}"
      errors[:haml] << message
      errors[:haml_error_files] << new_file
      results[:failure] << new_file
      puts message
    rescue => e
      messsage = "error #{e.class} #{e.message}"
      errors[:standard] << message
      results[:failure] << new_file
      puts message
    end
    if !validated
      puts "not modifying the file, we got bad haml"
    end
    validated
  end
  def new_file_name(file)
    new_file = file.gsub(/\.(erb|rhtml)$/,'') # let's not get too clever by adding html
    (new_file =~ /\.html$/) ? (new_file += '.haml') : (new_file += '.html.haml')
    new_file
  end
  def read_file(file)
    html = File.read(file)
    html.gsub(/(<\\[a-zA-Z])/m,"\n\\1").gsub("\t","  ").gsub(/\s+/m,' ').gsub(/<%([{@a-zA-Z])/m,'<% \\1')
  end
  def output(message)
    puts message
  end
end
e = ErbToHaml.new; nil
puts "non haml compile errors"
puts (Array(e.results[:failure]).sort - Array(e.errors[:haml_file_errors])).inspect
puts "duplicates"
puts e.errors[:duplicates].inspect
