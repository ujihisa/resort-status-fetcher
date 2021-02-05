require 'nokogiri'
require 'net/http'

module Fetcher
  def self.grouse()
    doc = Nokogiri::HTML(Net::HTTP.get(URI('https://www.grousemountain.com/current_conditions')))
    grouse = {
      runs: doc.at('#runs')./('li').map { _1.text.strip.split(/\n\n\n/).map(&:strip) }.to_json,
      lifts: doc.at('#lifts')./('li').map { _1.text.strip.split(/\n+/).map(&:strip) }.to_json,
      parks: doc.at('#parks')./('li').tap { _1.search('.//div').remove }.map { _1.text.strip.split(/\n+/).map(&:strip) }.to_json,
    }
  end
end

