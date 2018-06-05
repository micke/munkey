# frozen_string_literal: true

STDOUT.sync = true
require "bundler"
Bundler.require
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

LOGGER = Logger.new(STDOUT)

ENV["POSTGRES_HOST"] = "localhost"
ENV["POSTGRES_USERNAME"] = "mkswe"
ENV["POSTGRES_DATABASE"] = "mkswe"
ENV["POSTGRES_PASSWORD"] = ""

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + "/lib/*.rb").each{|f| require f}

DB.connect
DB.migrate

class I
  attr_reader :id
  def initialize(id)
    @id = id
  end
end

i = 0
it = ItemTracker.new([])

while true do
  it.add_and_return_new([I.new(i), I.new(i+1)])
  i += 2
  sleep 1
end
