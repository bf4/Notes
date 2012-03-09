require 'rubygems'
gem 'nokogiri', '=1.4.4'
require 'nokogiri'
gem 'loofah', '=1.2.0'
require 'loofah'
gem 'rspec', '=1.3.0'
require 'spec'

class WhiteListTagScrubber < Loofah::Scrubber
  attr_reader :tags, :attributes
  def initialize(options = {}, &block)
    @tags = Array(options.delete(:tags))
    @attributes = options.delete(:attributes) || {}
    super(options, &block)
  end
  def scrub(node)
    case node.type
    when Nokogiri::XML::Node::ELEMENT_NODE

      if tags.include? node.name
        # remove all attributes except the ones we whitelisted per tag
        node.attributes.each { |attr| node.remove_attribute(attr.first) unless Array(attributes[node.name]).include?(attr.first)}
        return Loofah::Scrubber::CONTINUE if node.namespaces.empty?
      else
        new_node_text = node_tagless_text(node)
        node.content = new_node_text
        if new_node_text == ""
          node.remove
        else
          node.replace new_text(node,new_node_text)
        end
        return Loofah::Scrubber::CONTINUE
      end
    when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
      return Loofah::Scrubber::CONTINUE
    end
    node.remove
    Loofah::Scrubber::STOP
  end
  # see https://github.com/flavorjones/mcbean/blob/master/lib/mcbean/markdown.rb
  def new_text(node, text)
    Nokogiri::XML::Text.new(text, node.document)
  end
  def node_tagless_text(node)
    node.children.map do |child|
      if child.text?
        child.text
      else
        if tags.include? child.name

          tag_cleaner(child) #if it's an allowed element in a disallowed element...  
          node_tagless_text(child)
        else
          node_tagless_text(child)
        end
      end
    end.compact.join(' ').strip
  end
  def tag_cleaner(node)
       # remove all attributes except the ones we whitelisted per tag
        node.attributes.each { |attr| node.remove_attribute(attr.first) unless Array(attributes[node.name]).include?(attr.first)}
  end
end

class CustomScrubber
  # uses Loofah
  def clean_html(html, tags=[],attributes={})
    #see RoundUpItem
    yield Loofah.fragment(html).scrub!(scrub_tags_except(tags,attributes)).to_s

  end
  # perhaps also see the scrubber
  # :newline_block_elements
  def line_breaks_to_br(html)
    html.gsub(/\r?\n/,'<br>')
  end
  # tags ian array of tags
  # attributes is a hash of the previous tags with an array of their whitelisted attributes
  # needs to be DRYed
  def scrub_tags_except(tags,attributes)
    options = {:tags => tags, :attributes => attributes }
    WhiteListTagScrubber.new(options)
  end
end

describe 'custom scrubber' do
  let(:updater) {CustomScrubber.new }
  all_attributes = ['id','class']
  tags_we_want = {'br' => [],
    'ol' => all_attributes,
    'ul' => all_attributes,
    'li' => all_attributes,
    'strong' => all_attributes,
    'p' => all_attributes,
    'i' => all_attributes,
    'em' => all_attributes,
    'a' => ['href','rel'].concat(all_attributes)
  }
  examples = {
    %q{<a href="hi">There</a><b class="hi">Dude</b>&nbsp;And<p style="display:none;">Later</p>} =>
    %q{<a href="hi">There</a>Dude&nbsp;And<p>Later</p>},
    %q{<strong class='test'>Testing<p id="foo" style="display:none;">and such</p></strong><br><h1>This rocks</h1><em>hi</em>} =>
    %q{<strong class="test">Testing<p id="foo">and such</p></strong><br>This rocks<em>hi</em>},
    %q{<h1>i'm in an <em>mmmmm</em></h1>'} =>
    %q{i'm in an <em>mmmmm</em>'}
    
  }
  puts "cleaning #{tags_we_want.inspect}"
  examples.each do |message_dirty,message_clean|  
    it "cleans up the the message" do
      updater.clean_html(message_dirty, tags_we_want.keys, tags_we_want) {|html| updater.line_breaks_to_br(html) }.should eql(message_clean)
    end
  end
end