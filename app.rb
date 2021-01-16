require 'sinatra'
require 'nokogiri'
require 'net/http'

set(:bind, '0.0.0.0')
set(:port, ENV['PORT'] || '8080')

get '/' do
  doc = Nokogiri::HTML(Net::HTTP.get(URI('https://www.grousemountain.com/current_conditions')))
  doc.at('#runs')./('li').map { _1.text.strip.split(/\n+/).map(&:strip) }.to_json
end
