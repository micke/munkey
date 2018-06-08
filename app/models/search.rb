# frozen_string_literal: true

class Search < ActiveRecord::Base
  belongs_to :user, counter_cache: true

  delegate :name, to: :user, prefix: true

  def self.find_by_id_or_query(id_or_query)
    if id_or_query =~ /^(\d+)$/
      find_by(id: $1.to_i)
    else
      query = Search.parse(id_or_query).query
      find_by(query: query)
    end
  end

  def self.matching(title, submitter)
    joins(:user)
      .where("users.blocked" => false)
      .where("(
              (
                wants IS FALSE AND to_tsvector(:have) @@ query OR
                wants IS TRUE AND to_tsvector(:want) @@ query
              ) AND (submitter ilike :submitter OR submitter IS NULL)
             ) OR query IS NULL AND submitter ilike :submitter",
             {
               have: title.have,
               want: title.want,
               submitter: submitter
             })
      .select("distinct on (users.id) searches.*")
  end

  def self.parse(args)
    search_query = Array(args).join(" ")
    search = new

    search.unparsed_query = search_query
    parsed_query = QueryParser.new.parse(search_query)

    parsed_query[:flags].each do |flag|
      case flag[:name]
      when "a"
        search.advanced = true
      when "w"
        search.wants = true
      when "u"
        search.submitter = flag[:value]
      end
    end

    cleaned_query = Utils.clean(parsed_query[:query].to_s)

    if search.advanced
      search.query = Search.find_by_sql(["SELECT to_tsquery(?) as query", cleaned_query]).first.query
    else
      search.query = Search.find_by_sql(["SELECT plainto_tsquery(?) as query", cleaned_query]).first.query
    end
    search.query = nil if search.query.blank?

    search
  rescue ActiveRecord::StatementInvalid => e
    puts e
    search.errors.add(:query, "Syntax error in query")
    search
  rescue Parslet::ParseFailed => failure
    puts failure.parse_failure_cause.ascii_tree
    search.errors.add(:query, failure.parse_failure_cause.ascii_tree)
    search
  end

  private

  def discord_user
    user.discord
  end
end
