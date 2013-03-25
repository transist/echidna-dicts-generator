module Freq
  class Learning

    DICT_PATH = 'dicts/learn.dict'

    def initialize()
      @segment = Freq::Segmenting.new(DICT_PATH)
      @stopword = Freq::Stopwording.new()
    end

    def process(source_id, text)
      chunks = get_segmented text
      
      serial = chars_serial(chunks)
      
      words = assemble_words(serial)
      
      analyze(source_id, text, chunks, words)
      
      words
    end

    def show
      mongo("idf").find({}, {sort: 'idf'}).first(1000).map do |item|
        {term: item["term"], tf: item["tf"], idf: item["idf"]}
      end.to_json
    end

    def save_to_file
      progressbar = ProgressBar.create(total: mongo("idf").count)

      File.open('dicts/terms.dic', 'w+') do |f|
        mongo("idf").find({}, {sort: 'idf'}).map do |item|
          f.puts "#{item["term"].length} #{item["term"]} #{item["idf"]} #{item["tf_idf"]}"
          f.flush
          progressbar.increment
        end
        f.close
      end
    end

    private

    def docs
      @docs_cursor ||= mongo('contents')
    end

    def mongo(coll)
      @db ||= $client['corpus']
      @db[coll.to_s]
    end

    def analyze source_id, text, chunks, words
      idfs, tfs, tf_idfs = [], [], []
      terms_count = chunks.count
      words.each do |word|
        t1 = Time.now.to_f
        tf = Freq::TermFrequency.tf text, terms_count, word
        t2 = Time.now.to_f
        idf = Freq::InverseDocumentFrequency.idf docs, word
        t3 = Time.now.to_f
        tf_idfs << {term: word, tf: tf, idf: idf, tf_idf: (tf * idf)}
        t4 = Time.now.to_f
        ap "Search in #{text.length} chars takes #{t4 - t1} seconds, tf: #{t2 - t1} seconds, idf: #{t3 - t2} seconds, tf_idf: #{t4 - t3} seconds."
      end

      doc = {
        source_id: source_id,
        terms: text,
        tf_idfs: tf_idfs
      }

      mongo(:terms).insert(doc)
    end

    def learn_new_words
      #@segment.load_dictionaies(DICT_PATH)
    end

    def get_segmented text
      @segment.segment(text)
    end

    def add_to_dict(words)
      File.open(DICT_PATH, 'a+') do |file|
        words.each do |word|
          file.puts "#{word.length} #{word}"
          file.flush
        end
        file.close
      end
    end

    def chars_serial(chunks)
      serial = []
      chunks.each_with_index do |chunk, index|
        w = @stopword.pick chunk
        serial << [index, w.join] if (w.length == 1 && w.join != '*')
      end
      serial
    end

    def assemble_words(serial)
      ret = []
      while serial.count > 0
        index = minimum_continuous_sequences serial.map(&:first), 0
        word = serial[0..index].map{|el| el[1]}.join
        ret << word unless index == 0
        serial = serial.drop(word.length)
      end
      ret.compact.uniq.sort
    end

    def continuous?(x, y)
      x + 1 == y
    end

    #minimum_continuous_sequences [3, 4, 5, 8, 9, 11, 12], 0 => 2
    def minimum_continuous_sequences(ary, index)
      if continuous?(ary[index], ary[index + 1])
        minimum_continuous_sequences(ary, index + 1)
      else
        index
      end
    end
  end
end