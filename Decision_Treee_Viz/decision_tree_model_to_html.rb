require 'json'

input = File.read(ARGV[0])

root = {}
stack = [root]
input.split("\n").each do |line|
  case line
  when /( *)(If||Else) \((.*)\)/
    layer = $1.length
    children = {}
    stack[layer][$3] = children
    stack[layer + 1] = children
  when /( *)Predict: (.*)/
    layer = $1.length
    stack[layer][$2] = nil
  end
end

def reduce(h)
  return h unless h.is_a? Hash
  val = nil
  diff = false
  h.each do |k, v|
    v = reduce v
    h[k] = v
    val ||= v
    if val != v
      diff = true
    end
  end
  if val and not diff
    val
  else
    h
  end
end

root = reduce root

# feature 1 not in {5.0,6.0,7.0,3.0,4.0}
FEATURES = [["Residents", "Non-residents", "Non-residents", "Foreign residents"],
            ["<= 8th grade", "High school graduate", "High school graduate", "Associate degree", "Associate degree", "Bachelors", "Masters", "Doctorate", "Education unknown"],
            ["Female", "Male"],
            ["<= 1 yr", "1- 4 yr", "5 - 14 yr", "15 - 24 yr", "25 - 34 yr", "35 - 44 yr", "45 - 54 yr", "55 - 64 yr", "65 - 74 yr", "75 - 84 yr", ">= 85", "Age not stated"],
            ["single", "Widowed", "Divorced", "Married", "Marital Status unknown"],
            ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
            ["Hospital", "Hospital", "Hospital", "Decedents home", "Hospice facility", "Nursing home", "Place of death unknown/Other", "Place of death unknown/Other"]]

PREDICT = ["Other/Unknown", "Burial", "Cremation"]

feature_set = FEATURES.map{ |fs| (0..(fs.size - 1)).to_a}

def to_human_readable h, feature_set
  return h unless h.is_a? Hash
  result = {}
  h.each do |k, v|
    if /feature (\d*) (not )?in {(.*)}/.match k
      subset = Marshal.load(Marshal.dump(feature_set))
      fid = $1.to_i
      if $2 # include "not"
        subset[fid] -= $3.split(',').map{ |f| f.to_i }
      else
        subset[fid] &= $3.split(',').map{ |f| f.to_i }
      end
      text = subset[fid].map{ |f| FEATURES[fid][f] }.uniq.join('<br/>')
      result[text] = to_human_readable(v, subset)
    else
      result[PREDICT[k.to_i]] = nil
      # raise "parse error: #{k}"
    end
  end
  result
end

root = to_human_readable(root, feature_set)

# def convert h
#   result = []
#   h.each do |k, v|
#     node = {name:k, value:10}
#     node[:children] = convert v if v
#     result << node
#   end
#   result
# end

def uuid
  @id = (@id || 0) + 1
end

def convert h, id
  result = []
  result << "<ul class=\"collapse\" id=\"i#{id}\">"
  h.each do |k, v|
    id = uuid
    result << '<li>'
    result << "<a href=\"#\" data-toggle=\"collapse\" data-target=\"#i#{id}\">#{k}</a>"
    result += convert(v, id) if v
    result << '</li>'
  end
  result << '</ul>'
  result
end

puts convert(root, 0).join('')
