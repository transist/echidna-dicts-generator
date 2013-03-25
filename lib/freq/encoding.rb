require 'active_support/concern'

module Freq
  module Encoding
    extend ActiveSupport::Concern
    
    module ClassMethods
      def to_utf8(text)
        cd = CharDet.detect(text)
        if cd.confidence > 0.6
          text.force_encoding(cd.encoding)
        end
        text.encode!("utf-8", :undef => :replace, :invalid => :replace, :replace => "?")
        text
      end
    end
  end
end