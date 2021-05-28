require "open-uri"
require "nokogiri"

class WikiController < ApplicationController
  def show
    topic = params[:topic]
    wiki_url = "https://en.wikipedia.org/wiki/#{topic}"
    logger.debug "wiki_url #{wiki_url}"

    # Fetch and parse HTML document
    doc = Nokogiri::HTML(URI.open(wiki_url))
    title = doc.search("//h1")
    file_contents = doc.search("div.mw-parser-output")

    render html: "
      <h1>#{title}</h1>
      <div>#{file_contents}</div>
    ".html_safe
  end
end
