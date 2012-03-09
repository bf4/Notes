find .  \( -iname '*query*' -o -iname '*search*' \)

perl -pi -w -e "s/File.dirname.*\/spec_helper/'spec\/spec_helper/g;"

find . -name '*_spec.rb' | grep -v 'helpers/shared' | grep -v 'helpers/vendor' | xargs ack 'spec_helper' | grep File | cut -d ':' -f 1 | sort -u | xargs perl -pi -w -e "s/require.*\/spec_helper.*/require 'spec_helper'/g;"

find . -name '*_spec.rb' | grep 'helpers/shared' | xargs ack 'spec_helper' | grep 'spec_helper' | grep '\.\.' |  cut -d ':' -f 1 | sort -u 

 | grep File | cut -d ':' -f 1 | sort -u | xargs perl -pi -w -e "s/require.*\/spec_helper.*/require 'spec_helper'/g;"


find app/views | xargs ack -l render | xargs ack partial | grep partial | perl -p -e '/partial(\s*?=>?\s*?\W?|\S+\(\W?)([a-z:A-Z\/_()#{}\.]+)([^,%\)]*)?([-,%\) ]|$)?/ && print "$2*"' | cut -d '*' -f 1 | sort -u | less

find app | xargs ack script | grep js | perl -p -e '/\S+?\W(\S+?js)\b/ && print "$1*"' | cut -d '*' -f 1 | awk '{urls[$1]++} END {for (url in urls) print urls[url], url}' | sort -nr | less


find app | xargs ack script | grep jquery | perl -p -e '/\S+?\W\S+?(jquery.*?[js|placeholder])\b/ && print "$1*"' | cut -d '*' -f 1 | awk '{urls[$1]++} END {for (url in urls) print urls[url], url}' | sort -nr | les

r to try to find partials that aren't called by looking at the dev log

find app/views | grep '/_' | cut -d '.' -f 1 | sort -u | cut -d '/' -f 3,4,5,6,7  > partials_files.out;  cat log/development.log* | grep 'Rendered' | cut -d '(' -f 1 | cut -d  ' ' -f 2 | sort -u > rendered_partials.out;  comm partials_files.out rendered_partials.out

this is just to find partials

find app/views | xargs ack -l render | xargs ack partial | grep partial | perl -p -e '/partial(\s*?=>?\s*?\W?|\S+\(\W?)([a-z:A-Z\/_()#{}\.]+)([^,%\)]*)?([-,%\) ]|$)?/ && print "$2*"' | cut -d '*' -f 1 | sort -u | less

ack 'script.*\.js' app | perl -p -e '/\S+?\W(\S+?\.js)\b/ && print "$1*"' | cut -d '*' -f 1 | sort | uniq -c | sort -n
/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
