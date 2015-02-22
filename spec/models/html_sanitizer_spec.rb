require "rails_helper"

describe HtmlSanitizer do
  it "sanitizes strings" do
    expect(HtmlSanitizer.sanitize("1 > 0")).to eq "1 &gt; 0"
  end

  it "sanitizes hash keys that do not end in _html" do
    expect(HtmlSanitizer.sanitize({body: "<p>great email</p>"})).to eq({body: "&lt;p&gt;great email&lt;/p&gt;"})
  end

  it "does not sanitize hash keys that end in _html" do
    expect(HtmlSanitizer.sanitize({body_html: "<p>great email</p>"})).to eq({body_html: "<p>great email</p>"})
  end

  it "sanitizes arrays of data objects recursively" do
    expect(HtmlSanitizer.sanitize([
      "1 > 0",
      {body: "<p>great email</p>"},
      {body_html: "<p>great email</p>"}
    ])).to eq([
      "1 &gt; 0",
      {body: "&lt;p&gt;great email&lt;/p&gt;"},
      {body_html: "<p>great email</p>"}
    ])
  end
end
