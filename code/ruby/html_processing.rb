require 'rubygems'
gem 'nokogiri', '=1.4.4'
require 'nokogiri'
gem 'loofah', '=1.2.0'
require 'loofah'
gem 'rspec', '~>1.3.1'
require 'spec'

class WhiteListTagScrubber < Loofah::Scrubber
  attr_reader :tags, :attributes
  def initialize(options = {}, &block)
    @tags = Array(options.delete(:tags))
    @attributes = options.delete(:attributes) || {}
    super(options, &block)
  end
  def debug(type,&block)
    if ENV['DEBUG'] =~ /true/i
      puts "**** #{type}, #{block.call.inspect}"
    end
  end
  def scrub(node)
    debug("processing") {  "#{node.type}: #{node.name}, namespaces #{node.namespaces.inspect}" }
    case node.type
    when Nokogiri::XML::Node::ELEMENT_NODE

      # see strip: return CONTINUE if html5lib_sanitize(node) == CONTINUE
      if tags.include? node.name
        # remove all attributes except the ones we whitelisted per tag
        clean_with_attributes(node,true)
        return Loofah::Scrubber::CONTINUE if node.namespaces.empty?
      else
        # remove all attributes
        clean_with_attributes(node,false)
        # remove the node and its contents entirely.
        # there's nothing good in these
        if %w{script style meta link}.include?(node.name)
          node.remove
        else
          # remove this undesired node and scrub each child node
          remove_node_and_add_children(node)
        end
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
    scrub(current_node) unless current_node == node
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
  # tags in an array of tags
  # attributes is a hash of the previous tags with an array of their whitelisted attributes
  # needs to be DRYed
  def scrub_tags_except(tags,attributes)
    options = {:tags => tags, :attributes => attributes }
    WhiteListTagScrubber.new(options)
  end
end

  def test_code(tags_we_want, examples)
    examples.each do |message_dirty,message_clean|
      it "cleans up the the message allowing \n\t#{tags_we_want.inspect}" do
        updater.clean_html(message_dirty, tags_we_want.keys, tags_we_want) do |html|
          updater.line_breaks_to_br(html)
        end.should eql(message_clean)
      end
    end
  end
describe 'custom scrubber' do
  STDOUT.sync = true
  let(:updater) {CustomScrubber.new }
  all_attributes = ['id','class']

  context "sample 1" do
    tags_we_want =
      {
      'br' => [],
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
      %q(NABL Presents:<br><br>OUTLAWS vs. CAPITALS<br><br>Monday April 9, 2012&nbsp;, 7pm <br><br>@ Nettleton Stadium<br><br>$10 General Admission<br>$25 VIP- rows 1-10<br>)


    }
    test_code(tags_we_want,examples)
  end


  describe 'permitted tags inside forbidden tags' do
    context 'with no permitted attributes' do
      tags_we_want = {
        'p' => [],
        'br' => []
      }

      examples = {
        %q{<p style="display:none;" class="foo">In a p <br /><b>I'm not bold</b><span class"bar">and I'm not in a span</span></p> and  <b><br />I'm not bold</b><span class"bar">and I'm not in a span</span>} =>
          %q{<p>In a p <br>I'm not boldand I'm not in a span</p> and  <br>I'm not boldand I'm not in a span}
      }
      test_code(tags_we_want,examples)
    end
    context 'with some permitted attributes' do
      tags_we_want =
        {
        'br' => [],
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
        %q{<p style="display:none;" class="foo">In a p <br /><b>I'm not bold</b><span class"bar">and I'm not in a span</span></p> and  <b><br />I'm not bold</b><span class"bar">and I'm not in a span</span>} =>
          %q{<p class="foo">In a p <br>I'm not boldand I'm not in a span</p> and  <br>I'm not boldand I'm not in a span},

        %q{<script>alert('hi');</script><strong><a href="http://example.com" class="link" id="thelink" rel="_blank" onclick="javascript:void();">Don't click <b>here</b></a><div id="content">Or look <center><script>alert('hi');</script>here</center></div></strong>"} =>
          %q{<strong><a href="http://example.com" class="link" id="thelink" rel="_blank">Don't click here</a>Or look here</strong>"}
      }
      test_code(tags_we_want,examples)
    end
  end
  context "sample 2" do
    tags_we_want = {
      'p' => [],
      'br' => []
    }
    examples = {
      %q{<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica">The New Fuse at Ace Bar</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; min-height: 14.0px"><br></p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica">The Ace Bar</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica">http://www.facebook.com/pages/The-Ace-Bar/185926308097124</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial; min-height: 15.0px"><br></p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial">1/31/2012.</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial; min-height: 15.0px"><br></p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial">Doors Open: 8.00 PM.</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial; min-height: 15.0px"><br></p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial">Ages 21+.</p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial; min-height: 15.0px"><br></p>
<p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial">The New Fuse:</p><p style="margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial"><span class="Apple-style-span" style="font-family: Helvetica, Arial, sans-serif, sans; font-size: 12px; line-height: 15px; ">Founded on a commitment to evolution, The New Fuse has developed into a creative juggernaut hell bent on improving, expanding their original repertoire. Each group member has a prolific propensity toward unforced composition and a desire to capture the songs, melodies born out of life. From the finest music school in the nation to the streets of Chicago the source of knowledge and inspiration for their original music runs deep.</span></p>} =>
              %q{<p>The New Fuse at Ace Bar</p><br><p><br></p><br><p>The Ace Bar</p><br><p>http://www.facebook.com/pages/The-Ace-Bar/185926308097124</p><br><p><br></p><br><p>1/31/2012.</p><br><p><br></p><br><p>Doors Open: 8.00 PM.</p><br><p><br></p><br><p>Ages 21+.</p><br><p><br></p><br><p>The New Fuse:</p><p>Founded on a commitment to evolution, The New Fuse has developed into a creative juggernaut hell bent on improving, expanding their original repertoire. Each group member has a prolific propensity toward unforced composition and a desire to capture the songs, melodies born out of life. From the finest music school in the nation to the streets of Chicago the source of knowledge and inspiration for their original music runs deep.</p>},

      %q{<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<title></title>
<meta name="Generator" content="Cocoa HTML Writer">
<meta name="CocoaVersion" content="1038.32">
<style type="text/css">
p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Georgia}
p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Georgia; min-height: 15.0px}
</style>


<p class="p1">JANUARY 27th - 8PM - THE COMEDY BAR &nbsp;</p>
<p class="p2"><br></p>
<p class="p1">WEB:&nbsp;http://comedybarchicago.com</p>
<p class="p2"><br></p>
<p class="p1">Located in heart of downtown Chicago, The Comedy Bar offers shows every Friday and Saturday at 8 &amp; 10pm for only 10 bucks.</p>
<p class="p2"><br></p>
<p class="p1">We have the funniest comedians, in the coolest venue, for the lowest price. Why the hell would you go anywhere else?</p>
<p class="p2"><br></p>
<p class="p1">COMEDIANS THIS WEEKEND:</p>
<p class="p2"><br></p>
<p class="p1">TBD</p>
<p class="p2"><br></p>
<p class="p1">THINGS TO KNOW:</p>
<p class="p2"><br></p>
<p class="p1">-- If a show is "Sold Out," please call The Comedy Bar at&nbsp;773-387-8412. They may have some available tickets at the door.</p>
<p class="p1">-- Tickets are non-refundable or exchangeable!&nbsp;</p>
<p class="p1">-- All shows are 21 and over. No dress code. No drink minimum!</p>
<p class="p1">-- Shows run about an hour and 15 minutes.</p>
<p class="p1">-- Doors open 30 minutes prior to show-time. Arriving at least 15 minutes before show time is always a good idea!</p>
<p class="p1">-- Seating is first come first serve. Please call The Comedy Bar if you have a group bigger than 5 to reserve seating for your group.</p>
<p class="p2"><br></p>
<p class="p1">Please call FanFueled with any payment related questions:&nbsp;312.321.0111</p>
<p class="p2"><br></p>
<p class="p1">Note: By purchasing tickets, you are joining the Comedy Bar mailing list.</p>} =>
              %q{<p>JANUARY 27th - 8PM - THE COMEDY BAR &nbsp;</p><br><p><br></p><br><p>WEB:&nbsp;http://comedybarchicago.com</p><br><p><br></p><br><p>Located in heart of downtown Chicago, The Comedy Bar offers shows every Friday and Saturday at 8 &amp; 10pm for only 10 bucks.</p><br><p><br></p><br><p>We have the funniest comedians, in the coolest venue, for the lowest price. Why the hell would you go anywhere else?</p><br><p><br></p><br><p>COMEDIANS THIS WEEKEND:</p><br><p><br></p><br><p>TBD</p><br><p><br></p><br><p>THINGS TO KNOW:</p><br><p><br></p><br><p>-- If a show is "Sold Out," please call The Comedy Bar at&nbsp;773-387-8412. They may have some available tickets at the door.</p><br><p>-- Tickets are non-refundable or exchangeable!&nbsp;</p><br><p>-- All shows are 21 and over. No dress code. No drink minimum!</p><br><p>-- Shows run about an hour and 15 minutes.</p><br><p>-- Doors open 30 minutes prior to show-time. Arriving at least 15 minutes before show time is always a good idea!</p><br><p>-- Seating is first come first serve. Please call The Comedy Bar if you have a group bigger than 5 to reserve seating for your group.</p><br><p><br></p><br><p>Please call FanFueled with any payment related questions:&nbsp;312.321.0111</p><br><p><br></p><br><p>Note: By purchasing tickets, you are joining the Comedy Bar mailing list.</p>},
#
    %q{<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<title></title>
<meta name="Generator" content="Cocoa HTML Writer">
<meta name="CocoaVersion" content="1038.32">
<style type="text/css">
p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial}
p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial; min-height: 15.0px}
</style>


<p class="p1">Get Off The Couch was the inspiration of a singer/songwriter named Sam Wahl who is now the host of this monthly showcase. New to Chicago in 2007 after relocating from Nashville,TN, Sam discovered just how vast the city of Chicago really was. Not just geographically, but musically as well.</p>
<p class="p2"><br></p>
<p class="p1">The number of original artists in the greater Chicago area that contribute to the soundtrack that is so specifically Chicago/American is astounding! There are a number of songwriter communities within the greater Chicago community and it can be a little overwhelming guessing where to begin attaching yourself as a newcomer to the city. Sam decided to take the "Field Of Dreams" approach. Figuring, if you build the showcase, the players will come. This would become a proven effective way to begin familiarizing ones self with the "communities" that be.</p><p class="p1"><br></p><p class="p1"><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<title></title>
<meta name="Generator" content="Cocoa HTML Writer">
<meta name="CocoaVersion" content="1038.32">
<style type="text/css">
p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Arial}
</style>


</p><p class="p1">Featuring:</p><p class="p1"><br></p><p class="p1">TBD</p><p></p>} =>
              %q{<p>Get Off The Couch was the inspiration of a singer/songwriter named Sam Wahl who is now the host of this monthly showcase. New to Chicago in 2007 after relocating from Nashville,TN, Sam discovered just how vast the city of Chicago really was. Not just geographically, but musically as well.</p><br><p><br></p><br><p>The number of original artists in the greater Chicago area that contribute to the soundtrack that is so specifically Chicago/American is astounding! There are a number of songwriter communities within the greater Chicago community and it can be a little overwhelming guessing where to begin attaching yourself as a newcomer to the city. Sam decided to take the "Field Of Dreams" approach. Figuring, if you build the showcase, the players will come. This would become a proven effective way to begin familiarizing ones self with the "communities" that be.</p><p><br></p><p></p><p>Featuring:</p><p><br></p><p>TBD</p><p></p>}
    }
    test_code(tags_we_want,examples)
  end
  context "sample 3" do
    tags_we_want =
      {
      'br' => [],
      'ol' => all_attributes,
      'ul' => all_attributes,
      'li' => all_attributes,
      'strong' => all_attributes,
      'p' => all_attributes,
      'i' => all_attributes,
      'em' => all_attributes,
      'a' => ['href','rel'].concat(all_attributes)
    }
    examples =
    {
      %q{<ul class="meta-usat"><li><strong>Album</strong>: Carnivale Electricos</li><li><strong>Artist</strong>: Galactic</li><li><strong>Release date</strong>: Feb. 21, 2012</li><li><strong class="download-song">Download</strong>: Hey Na Na, Magalenha</li></ul><p>&nbsp;</p><p>If you want to feel what you're missing by not being in New Orleans (or Rio) today for Mardi Gras, explore this funky, imaginative and contemporary primer. Galactic's style already is a melting pot of hip-hop, jazz, brass band and rock, and here the quintet and multiple guests add Brazilian elements and nods to zydeco, bounce, R&amp;B, marching bands and Mardi Gras Indian chants. Heavy, heady, sweaty, spiritual and absolutely true to the spirit of the day.</p><p>&nbsp;</p><p><a href="http://www.usatoday.com/life/music/reviews/story/2012-02-20/listen-up-albums-sinead-oconnor-sleigh-bells-galactic-fun/53179714/1">Read more &raquo;</a></p>} =>
      %q{<ul class="meta-usat"><br><li><br><strong>Album</strong>: Carnivale Electricos</li><br><li><br><strong>Artist</strong>: Galactic</li><br><li><br><strong>Release date</strong>: Feb. 21, 2012</li><br><li><br><strong class="download-song">Download</strong>: Hey Na Na, Magalenha</li><br></ul><p>&nbsp;</p><p>If you want to feel what you're missing by not being in New Orleans (or Rio) today for Mardi Gras, explore this funky, imaginative and contemporary primer. Galactic's style already is a melting pot of hip-hop, jazz, brass band and rock, and here the quintet and multiple guests add Brazilian elements and nods to zydeco, bounce, R&amp;B, marching bands and Mardi Gras Indian chants. Heavy, heady, sweaty, spiritual and absolutely true to the spirit of the day.</p><p>&nbsp;</p><p><a href="http://www.usatoday.com/life/music/reviews/story/2012-02-20/listen-up-albums-sinead-oconnor-sleigh-bells-galactic-fun/53179714/1">Read more &raquo;</a></p>}
    }
    test_code(tags_we_want,examples)
  end
end

