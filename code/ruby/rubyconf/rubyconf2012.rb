require 'json'
require 'open-uri'
require 'pp'
require 'time'
require 'date'
require 'tzinfo'

url = 'http://rubyconf2012.busyconf.com/event.json'
filename = File.expand_path(File.join(File.dirname(__FILE__),'event.json'))
if File.exists?(filename)
  doc = File.read(filename)
else
  doc = open(url).read
  File.open(filename, "w+") {|f| f.write(doc) }
end
json = JSON.parse(doc)

@time_slots = json['time_slots']
def time(slot_id)
  zone =  'America/Denver'
  tzinfo = TZInfo::Timezone.get(zone)
  time_slot = @time_slots.detect {|s| s['_id'] == slot_id }
  starts_at = tzinfo.utc_to_local(Time.parse(time_slot['starts_at']).utc)
  ends_at = tzinfo.utc_to_local(Time.parse(time_slot['stops_at']).utc)
  # title = time_slot['title']
  date = starts_at.strftime('%m-%d %a')
  start_time= starts_at.strftime('%H:%M')
  ends_time = ends_at.strftime('%H:%M')
  "#{date} #{start_time}-#{ends_time}"
end
pp json['activities'].map {|a|
  {:title => a['title'],
  :time => time(a['time_slot_id']),
   :description => a['description'],
   :speakers => a['speakers'].map {|s|
     {
       :name => s['name'],
       :company => s['company'],
       :headline => s['headline'],
       :bio => s['bio'],
       :url => s['url'],
       :twitter => s['twitter_username']
     }.inspect
   }.flatten
  }
}.sort {|a,b| a[:time] <=> b[:time] }; nil
