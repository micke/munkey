class QueryParser < Parslet::Parser
  root(:query)

  rule(:query) { flag.repeat(0).as(:flags) >> text.as(:query) }

  rule(:text) { spaces?.ignore >> any.repeat }

  rule(:flag) { spaces?.ignore >> str("-") >> (flag_without_value | flag_with_value) }
  rule(:flag_without_value) { match["aw"].as(:name) }
  rule(:flag_with_value) { match["u"].as(:name) >> spaced(str("=").maybe) >> (quoted_string | next_string).as(:value) }

  rule(:quoted_string) { dquoted_string | squoted_string }
  rule(:squoted_string) { squote.ignore >> (squote.absent? >> any).repeat >> squote.ignore }
  rule(:dquoted_string) { dquote.ignore >> (dquote.absent? >> any).repeat >> dquote.ignore }

  rule(:next_string) { match["0-9a-z\-_"].repeat(1) }

  rule(:squote) { match("[']") }
  rule(:dquote) { match("[\"]") }

  def spaced(rule)
    spaces? >> rule >> spaces?
  end

  rule(:s) { spaces? }
  rule(:spaces?) { spaces.maybe }
  rule(:spaces) { space.repeat }
  rule(:space) { str(" ") }

  def stri(str)
    key_chars = str.split(//)
    key_chars.
      collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
      reduce(:>>)
  end
end
