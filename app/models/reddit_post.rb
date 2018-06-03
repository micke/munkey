class RedditPost < SimpleDelegator
  def title
    @title ||= TitleParser.parse(__getobj__.title)
  end

  def raw_title
    __getobj__.title
  end

  def submitter
    __getobj__.author[/\/([\w_]+)$/, 1]
  end

  def submitter_url
    "https://reddit.com/u/#{submitter}"
  end

  def url
    __getobj__.link
  end

  delegate :gb?, to: :title

  def to_discord_message(search = nil)
    highlighted_title =
      search&.highlighted_query_match(title) ||
      title.to_s

    [
      nil,
      false,
      Discordrb::Webhooks::Embed.new(
        title: highlighted_title,
        url: url,
        author: Discordrb::Webhooks::EmbedAuthor.new(
          name: "/u/#{submitter}",
          url: submitter_url
        ),
        thumbnail: {
          "url": "https://i.imgur.com/4JZzObP.png"
        },
      )
    ]
  end

  def ==(other)
    other.id == self.id
  rescue NoMethodError
    super
  end

  def eql?(other)
    self == other
  end

  def method_missing(meth, *args)
    __getobj__.send(meth, *args)
  end

  def respond_to?(meth)
    __getobj__.respond_to?(meth)
  end
end
