hash = {
  'first' => 'value',
  'second' => [
    'elem1', 
    'elem2'
    ],
  'third' => {'fourth' => 'fifth'},
  'sixth' => {'seventh' => ['elem1','elem2','elem3']},
  'eighth' => [
    {'nineth' => 'tenth'},
    {'eleventh' => 'twelfth'},
    nil
    ]
}

def hash_path(hash,path)
  parts = path.split('/')
  find_hash_path(hash,parts)
end
def find_hash_path(hash,parts)
  if !parts.nil? && parts.size > 0

    test_part = parts.slice!(0)

    result = hash.detect {|k,v| k == test_part }
    if result.is_a?(Array)
      result = result[-1]
    end
    if result.is_a?(Array)
      result = result.detect {|item| find_hash_path(item,parts) }
    end
    if result.is_a?(Hash)
      result = find_hash_path(result,parts)
    end
  end
  
  result
end
puts hash_path(hash,'first').inspect
puts hash_path(hash,'third/fourth').inspect
puts hash_path(hash,'eighth/nineth').inspect
