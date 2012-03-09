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

      # see strip: return CONTINUE if html5lib_sanitize(node) == CONTINUE
      if tags.include? node.name
        # remove all attributes except the ones we whitelisted per tag
        clean_with_attributes(node,true)
        return Loofah::Scrubber::CONTINUE if node.namespaces.empty?
      else
        clean_with_attributes(node,false)
        remove_node_and_add_children(node)
        return Loofah::Scrubber::CONTINUE if node.namespaces.empty?
      end
    when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
      return Loofah::Scrubber::CONTINUE
    end
    node.remove
    Loofah::Scrubber::STOP
  end
  def remove_node_and_add_children(node)
    # alternatively see :strip
    # node.before node.children
    current_node = node
    node.children.each do |kid|
      previous_node = current_node
      current_node = current_node.add_next_sibling(kid)
      scrub(previous_node) unless previous_node == node
    end
    node.remove
  end
  def clean_with_attributes(node,use_attributes=true)
    attr_array = use_attributes ? attributes[node.name] : nil
    node.attributes.each { |attr| node.remove_attribute(attr.first) unless Array(attr_array).include?(attr.first)}
  end
end

class CustomScrubber
  # uses Loofah
  def clean_html(html, tags=[],attributes={})

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
    %q{i'm in an <em>mmmmm</em>'},
    %q(<div align="center"><b>NABL Presents:</b><br><br><b>OUTLAWS vs. CAPITALS</b><br><br><b>Monday April 9, 2012&nbsp;, 7pm </b><br><br><b>@ Nettleton Stadium</b><br><br><b>$10 General Admission</b><br><b>$25 VIP- rows 1-10</b><br></div>) =>
             %q(NABL Presents:   OUTLAWS vs. CAPITALS   Monday April 9, 2012&nbsp;, 7pm   @ Nettleton Stadium   $10 General Admission  $25 VIP- rows 1-10),


  }
  puts "cleaning #{tags_we_want.inspect}"
  examples.each do |message_dirty,message_clean|
    it "cleans up the the message" do
      updater.clean_html(message_dirty, tags_we_want.keys, tags_we_want) do |html|
        updater.line_breaks_to_br(html)
      end.should eql(message_clean)
    end
  end
end
