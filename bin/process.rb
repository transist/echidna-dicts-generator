ENV['FREQ_ENV'] ||= "development"

require "bundler"
Bundler.require(:default, ENV['FREQ_ENV'])

require './lib/freq'
require 'optparse'

include Mongo

DATABASE_NAME = 'corpus'

@db = $client[DATABASE_NAME]
@contents_coll = @db['contents']
@terms_coll = @db['terms']
@idf = @db["idf"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: process.rb [options]"

  opts.on("-a", "--analyze", "Analyze the terms") do |a|
    options[:analyze] = a
  end

  opts.on("-s", "--save", "Save to file") do |s|
    options[:save] = s
  end
end.parse!

l = Freq::Learning.new

if options[:analyze]
  @terms_coll.find.each do |terms|
    terms["tf_idfs"].each do |term|
      idf_term = @idf.find(term: term["term"]).first
      puts "Start to process term: #{term['term']}..."
      if idf_term
        @idf.update({"_id" => idf_term["_id"]}, {"$set" => {tf: idf_term["tf"] + term["tf"], tf_idf: idf_term["tf_idf"] + term["tf_idf"]}})
        puts "Updated #{term['term']}..."
      else
        @idf.insert({term: term["term"], tf: term["tf"], idf: term["idf"], tf_idf: term["tf_idf"]})
        puts "Inserted #{term['term']}..."
      end
      puts "...Done"
    end
  end
elsif options[:save]
  l.save_to_file
else
  @contents_coll.find.each do |content|
    unless @terms_coll.find(source_id: content["_id"]).count > 0
      puts "Start to process topic: #{content['topic_id']}, source_id: #{content["_id"]}..."
      l.process content["_id"], content["content"]
      puts "...Done"
      puts
      puts
    else
      puts "Skip topic: #{content['topic_id']}, source_id: #{content["_id"]}"
    end
  end
end

