#!/usr/bin/ruby
require 'optparse'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'csv'

options = {}
options[:number] = 100
options[:delay] = 1
options[:geo] = "true"
options[:identified] = "true"
options[:photos] = "true"
options[:rank] = "species"
options[:verifiable] = "true"
options[:resolution] = "medium"
options[:species] = ""
options[:dir] = ""

OptionParser.new do |opts|
  #Defaults
  opts.banner = "dwn_pics: Downloading iNaturalist pictures for species\nUsage: search.rb [options]\n./dwn_pics.rb -s 'quercus' -n 10 -f /home/will/ -o metadata.txt\n\n"
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on("-n NUMBER", "--number NUMBER", "Download NUMBER entries (default: 100") {|x| options[:number] = x.to_i}
  opts.on("-d DELAY", "--delay DELAY", "How many seconds to wait between downloads (default: 1)") {|x| options[:delay] = x.to_i}
  opts.on("-o OUTPUT", "--output FILE", "Name of file to write output to") {|x| options[:output] = x.to_s}
  opts.on("-f DIR", "--folder DIRECTORY", "Directory for images") {|x| options[:dir] = x.to_s}
  opts.on("-g GEO", "--geo BOOL", "Whether obs. are geo-referenced (default: true)") {|x| options[:geo] = x.to_s}
  opts.on("-i IDENT", "--ident BOOL", "Whether obs. are identified (default: true)") {|x| options[:identified] = x.to_s}
  opts.on("-r RANK", "--rank LEVEL", "Taxonomic level for identification (default: species)") {|x| options[:rank] = x.to_s}
  opts.on("-s SPECIES", "--species NAME", "Species to search for (default: blank)") {|x| options[:species] = x.to_s}
  opts.on("-v VERIFIABLE", "--verifiable BOOL", "Search for verifiable (reserch grade and IDed) (default: true)") {|x| options[:verifiable] = x.to_s}
  opts.on("-r RESOLUTION", "--resolution TEXT", "Picture download size/resolution (default: medium)") {|x| options[:resolution] = x.to_s}
  opts.on("-")
end.parse!

taxon_id = JSON.parse(open("http://api.inaturalist.org/v1/taxa/autocomplete?q=#{options[:species]}").read)["results"][0]["id"]
puts "Downloading TaxonID #{taxon_id}"

curr_page = 1; downloaded = 0
CSV.open(options[:output], "w") do |row|
  row << ["id", "species", "lat", "long", "date_time", "image_url"]
  Dir.chdir options[:dir]
  while downloaded < options[:number]
    page = JSON.parse(open("http://api.inaturalist.org/v1/observations?geo=#{options[:geo]}&identified=#{options[:identified]}&photos=true&rank=#{options[:rank]}&order=desc&order_by=created_at&taxon_id=#{taxon_id}&verifiable=#{options[:verifiable]}&page=#{curr_page}").read)
    if page["total_results"] <= downloaded then exit end
    page["results"].each do |record|
      id = record["id"]
      species = record["taxon"]["name"]
      lat = record["geojson"]["coordinates"][1]
      long = record["geojson"]["coordinates"][0]
      date_time = record["time_observed_at"]
      image_url = record["photos"][0]["url"]
      row << [id, species, lat, long, date_time, image_url]
      downloaded += 1
      open("#{id}.jpg", "wb") {|x| x << open(image_url.sub("square",options[:resolution])).read}
      if page["total_results"] <= downloaded then exit end
      if downloaded == options[:number] then exit end
      sleep options[:delay]
    end
    curr_page += 1
  end
end
