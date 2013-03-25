#encoding: utf-8
require "bundler"
Bundler.require(:default)

require './lib/freq'

DATABASE_NAME = 'corpus'

@db     = $client[DATABASE_NAME]
@groups_coll   = @db['groups']
@contents_coll = @db['contents']
 
def to_utf8(html)
  cd = CharDet.detect(html)
  if cd.confidence > 0.6
    html.force_encoding(cd.encoding)
  end
  html.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
  html
end

def get_html(url)
  begin
    html = RestClient.get url
  rescue => e
    puts e.response
  end
  Nokogiri::HTML(to_utf8(html)) unless html.nil?
end

root_url = 'http://www.douban.com/group/explore'

html = get_html(root_url)

html.css('.group-list .title h3 a').each do |link|
  url = link.attributes["href"].value
  doc = {
    group_name: url.gsub(/http:\/\/www.douban.com\/group\//, '').gsub(/\//, ''),
    url: url
  }

  @groups_coll.insert(doc) unless @groups_coll.find('group_name' => doc[:group_name]).count > 0
end

puts "Got all groups."

@groups_coll.find.each do |row|

  html = get_html(URI.join(row["url"], "discussion").to_s)
  while !html.css('.paginator .next a').empty?
     topics = html.css('#group-topics .title a')

    url = html.css('.paginator .next a').first.attributes["href"].value
    html = get_html(url)

    topics = html.css('.article .title a')

    topics.each do |topic|
      topic_url = topic.attributes['href'].value
      topic_id = topic_url.gsub(/http:\/\/www.douban.com\/group\/topic\//, '').gsub(/\//, '')

      unless @contents_coll.find('topic_id' => topic_id).count > 0
        puts ""
        puts "Start to fetch from #{topic_url}..."

        topic_html = get_html(topic_url)

        unless topic_html.nil?
          topic_doc = {}
          topic_doc['url'] = topic_url
          topic_doc['topic_name'] = topic.text
          topic_doc['topic_id'] = topic_id
          topic_doc['group_name'] = row['group_name']
          topic_doc['content'] = topic_html.css('.topic-doc .topic-content p').text
          topic_doc['content'] << topic_html.css('#comments .reply-doc p').text

          @contents_coll.insert(topic_doc)
        end
        puts "...done"
      else
          puts "fetched. skip."
      end
      
    end
  end
end





