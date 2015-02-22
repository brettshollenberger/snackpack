class EmailAddressFormatter
  def format_address(name, address)
    name = strip_chars(name)

    name.present? ? name_plus_address(name, address) : address
  end

  def name_plus_address(name, address)
    "#{proper_name(name)} <#{address}>"
  end

  def proper_name(name)
    has_special_char(name) ? '"' + name + '"' : name
  end

  # Strips characters that are illegal in the display name
  def strip_chars(name)
    return nil if name.nil?

    name.tr("'\"", "")
  end

  # Checks whether the display name has any characters that need to 
  # be quoted
  def has_special_char(name)
    special_chars.any? { |char|
      name.include? char
    }
  end

  # A list of characters that if occurring in the display name,
  # will trigger the display name to be wrapped in quotes
  def special_chars
    [":", "<", ">", "@", ",", ";", "[", "]", "&"]
  end
end

