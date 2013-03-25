module Freq
  class Segmenting
    include Freq::Encoding

    require 'rmmseg'

    def initialize(*dicts)
      load_dictionaies(*dicts)
    end

    def segment(text)
      algorithm = RMMSeg::Algorithm.new(text)

      result = []
      while token = algorithm.next_token
        result << token.text
      end

      result.map{|el| el.force_encoding('utf-8') }
    end

    def load_dictionaies(*dicts)
      add_dictionary(*dicts)
      refresh_dictionary
    end

    def add_dictionary(*dicts)
      dicts.each{|dict| RMMSeg::Dictionary.dictionaries << [:words, dict]}
    end

    def refresh_dictionary
      RMMSeg::Dictionary.load_dictionaries
    end
  end
end