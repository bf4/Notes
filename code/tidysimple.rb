#!/usr/bin/ruby
#*http://webcache.googleusercontent.com/search?q=cache:e76nAvo2-CMJ:snippets.rorbuilder.info/posts/show/215+/search%3Fhl%3Den%26q%3D%2Bsite:rorbuilder.info%2Bxml%2Btidy%2Bruby&cd=3&hl=en&ct=clnk&gl=us&source=www.google.com*
require 'stack'

class TidySimple
  def initialize(html)
    puts self.go(html)
  end

  def get_start_tag(s,buffer)
    remainder = ''
    start_element = buffer[/^<[^>]+>([^<]+)?(?=<[^\/])/]
    remainder = $'

    unless start_element.nil? then
      start_tag = start_element[/\w+/]

      s.push(start_tag)
      buffer = remainder
      remainder = get_start_tag(s,buffer)
    else

      start_element = buffer[/<[^>]+>/]
                        
      unless start_element.nil? then
        remainder = $'
        start_tag = start_element[/\w+/]
        s.push(start_tag)

      end
    end

    return remainder
  end

  def go(a)
    s = Stack.new
    remainder = self.get_start_tag(s,a)
    i = a.index(remainder)

    validated = Array.new
    remainder4 = self.get_end_tag(s, validated, remainder)

    return fix_element_attribs(a.slice(0,i)) + validated.join, remainder4    
  end

  def get_end_tag(s, validated, buffer)
    start_tag = s.pop()

    unless buffer.match(/^([^<]+)?<\/#{start_tag}>/) then
      #check for siblings

      if buffer.match(/^([^<]+)?(<[^\/]+[^>]+>.*$)/) then
        # found some siblings'
        validated << $1
        buffer2 = $2

        fragment, remainder2 = go(buffer2)
        validated << fragment

        k = buffer.index(buffer2)

        buffer.slice!(k,buffer2.length)
        s.push(start_tag)
        remainder = self.get_end_tag(s, validated, remainder2)

      else
        pos = buffer.index(/</)

        if not pos.nil? then
          #insert the new closing tag at position x
          buffer.insert pos, "</" + start_tag + ">"     
        else
          buffer = "</" + start_tag + ">"     
        end

      end

    end
    # chop off the found closing tag and store it
    validated << buffer[/^([^<]+)?<\/#{start_tag}>/]

    remainder = $'
    remainder = '' if remainder.nil?   

    remainder = get_end_tag(s, validated, remainder) unless  s.count <= 0
    return remainder
  end

  def fix_attribs(a)
    attribs = a.split(/\s/).map do |p|
      p[/(\w+)=("|')?([^("|')]*)/]

      attrib = ($1.nil?) ? 'attrib' : $1
      attrib_val = ($3.nil?) ? '' : $3
      attrib + "=" + "'" + attrib_val.gsub("&","&amp;") + "'"
    end
    attribs.join(' ')
  end

  def fix_element_attribs(buffer)
    buffer.scan(/<[^>]+>/).each do |p|
      a = p[/<\w+\s+(.*)\/?>/,1]
      unless a.nil? then
        attrib_line = fix_attribs(a)     
        buffer.sub!(a,attrib_line)
      end
    end
    buffer
  end
end
