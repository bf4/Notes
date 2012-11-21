# https://twitter.com/sferik/statuses/201331116127436800
# outputs a graph of the Ruby object hierarchy in DOT format. (Open it with graphviz.)
n,e=[],{};ObjectSpace.each_object(Class){|k|n<<k;k.superclass&&e[k]=k.superclass};puts"digraph{";n.map{|c|p c};e.map{|k,v|puts"#{k}->#{v}"}

# https://twitter.com/moonbeamlabs/statuses/202029423527071744
# todolist
# ruby -e'a=[];loop{c,j=(b=gets).to_i,0;system "clear";c>0 ? a.delete_at(c-1) : a<<b;a.map{|i|puts "#{j+=1}: #{i}"};}'

# https://twitter.com/panthomakos/status/202778451751600130
# Will the last command you ran fit in a tweet? fc -ln -1 | ruby -e 'puts ARGF.read.length'
#
# # https://twitter.com/panthomakos/status/203511992084987904
# https://twitter.com/panthomakos/status/203511699322580992
# hangman
# ruby -e'e=" ";w=`cat /usr/share/dict/words`.split.sample;loop{g=w.gsub /[^#{e}]/,"_";p g;exit if g==w;e+=gets.chomp;exit 1 if e.size>16}'

# https://github.com/adparadise/roguesgolf_todo
# ruby -e'`touch .d/t`;r=IO.readlines".d/t";File.new(".d/t","w").write (r+$*).sort.map(&:strip).uniq.join"\n"' $*
# 
# #
# https://twitter.com/theaboutbox/status/203509764007796737
# ruby -e'print"letters: ";s=$<.gets;open("/usr/share/dict/words").each{|w|$><<w if w.chars.inject(1){|a,c|a&&s.count(c)>=w.count(c)}}'

# https://twitter.com/panthomakos/status/202778838877483008
# ruby -e'system "clear";puts "\n"*(`tput lines`.to_i/2);loop{print "\r",Time.now.strftime(" %T ").center(`tput cols`.to_i,"*")}'


