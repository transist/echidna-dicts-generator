module Freq
  class TermFrequency

    class << self
      def tf(text, terms_count, term)
        count_terms_term = text.count(term)
        count_terms_term.to_f / terms_count.to_f
      end
    end
    
  end
end