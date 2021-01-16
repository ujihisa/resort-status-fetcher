require 'sinatra'
require 'nokogiri'
require 'net/http'
require 'google/cloud/firestore'

set(:bind, '0.0.0.0')
set(:port, ENV['PORT'] || '8080')

firestore = ::Google::Cloud::Firestore.new(
  project_id: 'devs-sandbox',
  **(File.exist?('devs-sandbox-5941dd8999bb.json') ? { credentials: 'devs-sandbox-5941dd8999bb.json' } : {}))

get '/' do
  doc = Nokogiri::HTML(Net::HTTP.get(URI('https://www.grousemountain.com/current_conditions')))
  grouse = {
    runs: doc.at('#runs')./('li').map { _1.text.strip.split(/\n\n\n/).map(&:strip) }.to_json,
    lifts: doc.at('#lifts')./('li').map { _1.text.strip.split(/\n+/).map(&:strip) }.to_json,
    parks: doc.at('#parks')./('li').tap { _1.search('.//div').remove }.map { _1.text.strip.split(/\n+/).map(&:strip) }.to_json,
  }

  now = Time.now
  firestore.col('ujihisa-test').add({
    time: now,
    grouse: grouse,
  })

  {
    time: now.iso8601,
    grouse: grouse,
  }.to_json
end
