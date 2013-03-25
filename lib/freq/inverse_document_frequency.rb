module Freq
  class InverseDocumentFrequency

    class << self
      def idf docs, term
        Math.log2(docs.count.to_f / included_count_plus_one(docs, term))
      end

      def included_count_plus_one(docs, term)
        count = 0
        docs.find.each do |doc|
          count += 1 if doc["content"].include? term
        end
        count +=1
      end
    end
  end
end