module Freq
  class Stopwording

    DICT_PATH = 'dicts/stopwords.dict'

    def initialize()
      load_stopwords
    end

    def pick(str)
      chars = str.chars.to_ary
      index = 0
      while index < chars.length
        c = chars[index]
        if @stopword_hash.include? c
          @stopword_hash[c].map(&:length).uniq.sort{ |x, y| y <=> x }.each do |length|
            if @stopword_hash[c].include? chars[index, length].join()
              (index..index + length - 1 ).each{ |i| chars[i] = "*" }
              break
            end
          end
        end
        index = index + 1
      end

      chars
    end

    private

    def load_stopwords
      @stopwords ||= File.open(DICT_PATH, 'r') do |file|
        file.each_line.map do |line|
          line.strip
        end
      end

      @stopword_hash = {}
      @stopwords.each do |w|
        if @stopword_hash.key? w.chars.first
          @stopword_hash[w.chars.first] << w
        else
          @stopword_hash[w.chars.first] = [w]
        end
      end
    end
  end
end