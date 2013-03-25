#encoding: utf-8

require 'rchardet19'

def to_utf8(text)
  cd = CharDet.detect(text)
  if cd.confidence > 0.6
    text.force_encoding(cd.encoding)
  end

  begin
    text.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
  rescue
    text.force_encoding('GB2312')
    text.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
  end
  text
end

ARGV.each do |path|
  File.open(path, 'r') do |file|
    new_name = File.path(file).gsub(File.extname(file), '') + 'utf8' + File.extname(file)
    new_file = File.new(new_name, 'w')
    file.each_line.each do |line|
      new_file.puts to_utf8(line)
      new_file.flush
    end

    new_file.close
  end
end