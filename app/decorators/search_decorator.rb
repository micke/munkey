# frozen_string_literal: true

class SearchDecorator < SimpleDelegator
  def highlighted_query_match(title)
    haystack = wants? ? title.want : title.have
    highlight = Search.find_by_sql(
      [
        "SELECT ts_headline(?, query, 'StartSel=__,StopSel=__,ShortWord=1,HighlightAll=true') as title
        FROM searches
        WHERE id=?",
        haystack,
        id
      ]
    ).first.title
    s = "[#{title.location}]".dup

    if wants?
      s << "[H] #{title.have} [W] #{highlight}"
    else
      s << "[H] #{highlight} [W] #{title.want}"
    end
    s
  end

  def description
    [
      wants_description,
      query_description,
      submitter_description
    ].join(" ")
  end

  private

  def wants_description
    wants? ? "[W]" : "[H]"
  end

  def query_description
    query.present? && "`#{query}`" || "**anything**"
  end

  def submitter_description
    "posted by `#{submitter}`" if submitter
  end
end
