class TitleParser < Parslet::Parser
  root(:title)

  rule(:title) {
    spaced(location) >> spaced(h) >> spaced(text.as(:have)) >> spaced(w) >> spaced(text.as(:want)) |
    spaced(other) >> any.repeat.as(:have)
  }

  rule(:text) { (spaces? >> open.absent? >> any).repeat }

  rule(:location) { spaced(open)>> (us | ca | eu | other_country) >> spaced(close) }
  rule(:us) { stri("US").as(:country) >> spaced(seperator?) >> alpha2.as(:state) }
  rule(:ca) { stri("CA").as(:country) >> spaced(seperator?) >> alpha2.as(:province) }
  rule(:eu) { stri("EU").as(:region) >> spaced(seperator?) >> alpha2.as(:country) }
  rule(:other_country) { alpha2.as(:country) }

  rule(:other) { spaced(open) >> alphas.as(:other) >> spaced(close) }

  rule(:alpha2) { match("[A-Za-z]").repeat(2, 2) }
  rule(:alphas) { match("[A-Za-z]").repeat(1) }

  rule(:h) { spaced(open) >> match("[Hh]") >> spaced(close) }
  rule(:w) { spaced(open) >> match("[Ww]") >> spaced(close) }

  def spaced(rule)
    spaces? >> rule >> spaces?
  end

  rule(:s) { spaces? }
  rule(:spaces?) { spaces.maybe }
  rule(:spaces) { space.repeat }
  rule(:space) { str(" ") }

  rule(:open) { str("[") }
  rule(:close) { str("]") }
  rule(:seperator?) { seperator.maybe }
  rule(:seperator) { str("-") }

  def stri(str)
    key_chars = str.split(//)
    key_chars.
      collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
      reduce(:>>)
  end

  def self.parse(string)
    title = new.parse(string)
    Title.new(title)
  end
end

class Title
  attr_reader :region, :country, :state, :have, :want, :other

  def initialize(region: nil, country: nil, state: nil, have:, want: nil, other: nil)
    @region = region&.to_s
    @country = country&.to_s
    @state = state&.to_s
    @have = have&.to_s
    @want = want&.to_s
    @other = other&.to_s
  end

  def location
    country || other
  end

  def gb?
    !region && location =~ /^gb|ic$/i
  end

  def to_s
    s = "[#{location}]"
    if have && want
      s << "[H] #{have} [W] #{want}"
    else
      s << " #{have}"
    end
    s
  end
end
