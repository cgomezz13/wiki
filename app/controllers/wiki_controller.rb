require "open-uri"
require "nokogiri"
require "pig_latinify"

class WikiController < ApplicationController
  def show
    topic = params[:topic]
    wiki_url = "https://en.wikipedia.org/wiki/#{topic}"
    logger.debug "wiki_url #{wiki_url}"

    # Fetch and parse HTML document
    doc = Nokogiri::HTML(URI.open(wiki_url))
    title = doc.search("//h1")
    file_contents = doc.search("div.mw-parser-output")

    file_contents.search("//table").each do |table|
      table["class"] = "wiki-table"
    end

    # wiki table
    lines = file_contents.search("table.wiki-table caption", "table.wiki-table tr th", "table.wiki-table tr td")
    lines.each do |check|
      # avoid media table cells
      if !(check.to_s.include?("flagicon") || check.to_s.include?("image") || check.to_s.include?("mediaContainer"))
        check.content = pig_latinify(check.text)
      end
    end


    # headers of each section
    lines = file_contents.search("span.mw-headline")
    lines.each do |check|
      check.content = pig_latinify(check.text)
    end

    # captions of sections and images
    lines = file_contents.search("div.hatnote, div.infobox-caption, div.thumbcaption")
    lines.each do |check|
      check.content = pig_latinify(check.text)
    end

    # table of contents
    toc = file_contents.search("div.toc h2, div.toc span.toctext")
    toc.each do |check|
      check.content = pig_latinify(check.text)
    end

    # Info box table (main description card)
    lines = file_contents.search("table.infobox caption.infobox-title", "table.infobox th.infobox-label", "table.infobox td.infobox-data")
    lines.each do |check|
      check.content = pig_latinify(check.text)
    end

    # main content
    # to add these ruins translation of images: "//a", "//td"
    # "//ul//li"
    lines = file_contents.search("//h2//span//a", "//h3//span//a", "//h4//span//a", "//p")
    lines.each do |check|
      check.content = pig_latinify(check.text)
    end

    render html: "
      <h1>#{title}</h1>
      <div>#{file_contents}</div>
    ".html_safe
  end
end
