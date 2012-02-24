require 'benchmark'
n = 1000000
starting_point = "hi"
value_start = 'bye'
values = (0..n).map do |i|
  "#{value_start}#{i}"
end

# string_keys = %w{hi there dude i look the way you look 42}
# symbol_keys = string_keys.map {|k| k.to_sym }
# values = %w{this is just a test that you may not like}
# string_keys_hash = {}
# symbol_keys_hash = {}
# string_keys.each_with_index do |key, index|
#   string_keys_hash[key] = values[index]
#   symbol_keys_hash[symbol_keys[index]] = values[index]
# end
Benchmark.bmbm do |bm|
  bm.report("with string keys") { 
    string_keys = (0..n).map do |i|
      "#{starting_point}#{i}"
    end
    string_keys_hash = {}
    string_keys.each_with_index do |key, index|
      string_keys_hash[key] = values[index]
    end

    string_keys.each do |key|
      string_keys_hash[key]
    end
  }
  bm.report("with symbol keys") { 
    symbol_keys = (0..n).map do |i|
      "#{starting_point}#{i}".to_sym
    end
    symbol_keys_hash = {}
    symbol_keys.each_with_index do |key, index|
      symbol_keys_hash[key] = values[index]
    end
    symbol_keys.each do |key|
      symbol_keys_hash[key]
    end
  }
end
