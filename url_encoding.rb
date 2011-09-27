require 'cgi'
require 'open-uri'
puts "to quote html and urls use CGI.escape (CGI.unescape)"
puts "this type of escape would be used in query parameters"
puts CGI.escape( "Nicholas Payton/Trumpet & Flugel Horn" )
puts CGI.escapeHTML( '<a href="/mp3">Click Here</a>' )
puts CGI.escapeElement('<hr><a href="/mp3">Click Here</a><br>','A') #only the a tag is escaped
# http://corelib.rubyonrails.org/classes/CGI.html
#URL-encode a string.

#  url_encoded_string = CGI::escape("'Stop!' said Fred")
     # => "%27Stop%21%27+said+Fred"
     # Extracts URIs from a string. If block given, iterates through all matched URIs. Returns nil if block given or array with matches.
puts "URI.escape has been deprecated in Ruby 1.9.2... so use CGI::escape"
#########
foo = "http://google.com?query=hello"

uri_good = URI.escape(foo, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
cgi_good = CGI.escape(foo)

puts uri_good == cgi_good # => true

###################
puts "to fully escape a uri"
val = URI.escape("abc&efg?hijk", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
foo = "http://google.com?query=hello"

bad = URI.escape(foo)
good = URI.escape(foo, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

bad_uri = "http://mysite.com?service=#{bad}&bar=blah"
good_uri = "http://mysite.com?service=#{good}&bar=blah"

puts bad_uri
# outputs "http://mysite.com?service=http://google.com?query=hello&bar=blah"

puts good_uri
# outputs "http://mysite.com?service=http%3A%2F%2Fgoogle.com%3Fquery%3Dhello&bar=blah"

###################

# cgi = CGI.new
# h = cgi.params
# cgi['queryparam1']

# require "cgi"
# cgi = CGI.new("html3")  # add HTML generation methods
# cgi.out{
#   cgi.html{
#     cgi.head{ "\n"+cgi.title{"This Is a Test"} } +
#     cgi.body{ "\n"+
#       cgi.form{"\n"+
#         cgi.hr +
#         cgi.h1 { "A Form: " } + "\n"+
#         cgi.textarea("get_text") +"\n"+
#         cgi.br +
#         cgi.submit
#       }
#     }
#   }
# }

# cookie = CGI::Cookie.new("rubyweb", "CustID=123", "Part=ABC");
# cgi = CGI.new("html3")
# cgi.out( "cookie" => [cookie] ){
#   cgi.html{
#     "\nHTML content here"
#   }
# }

# require "cgi/session"
# 
# cgi = CGI.new("html3")
# sess = CGI::Session.new( cgi, "session_key" => "rubyweb",
#                           "session_id"  => "9650",
#                           "new_session" => true,
#                           "prefix" => "web-session.")
# sess["CustID"] = 123
# sess["Part"] = "ABC"
# 
# cgi.out{
#   cgi.html{
#     "\nHTML content here"
#   }
# }