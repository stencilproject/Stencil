def header(title)
  line = "==> #{title}..."
  if `tput colors`.chomp.to_i >= 8
    puts "\e[1;32m" + line + "\e[0m"
  else
    puts line
  end
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
