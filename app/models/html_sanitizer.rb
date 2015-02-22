class HtmlSanitizer
  class << self
    # Public: HTML escape values. It does not escape the keys that end with _html.
    #
    # value - input value.
    #
    # Returns sanitized value.
    #
    def sanitize(value)
      case value
      when String, Hash, Array then sanitize_type(value)
      else value
      end
    end

  private
    def sanitize_type(value)
      send("sanitize_#{value.class.name.downcase}", value)
    end

    def sanitize_string(value)
      ERB::Util.html_escape(value)
    end

    def sanitize_hash(value)
      value.each do |k, v|
        value[k] = k.to_s =~ /_html$/ ? v : sanitize(v)
      end
    end

    def sanitize_array(value)
      value.map { |v| sanitize(v) }
    end
  end
end
