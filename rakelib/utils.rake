def colorize(string, *codes)
  if `tput colors`.chomp.to_i >= 8
    code = codes.join(';')
    puts "\e[#{code}m" + string + "\e[0m"
  else
    puts string
  end
end

def header(title)
  puts colorize("==> #{title}...", 1, 32) # bold, green
end

def info(string)
  puts colorize(string, 34) # blue
end

def release_branch(version)
  "release/#{version}"
end

def replace(file, replacements)
  content = File.read(file)
  replacements.each do |match, replacement|
    content.gsub!(match, replacement)
  end
  File.write(file, content)
end
