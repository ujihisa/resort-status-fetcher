require './lib/fetcher'
require 'sinatra'
require 'google/cloud/firestore'

set(:bind, '0.0.0.0')
set(:port, ENV['PORT'] || '8080')

firestore = ::Google::Cloud::Firestore.new(
  project_id: 'devs-sandbox',
  **(File.exist?('devs-sandbox-5941dd8999bb.json') ? { credentials: 'devs-sandbox-5941dd8999bb.json' } : {}))

get '/' do
  grouse = Fetcher.grouse()
  grouse_tickets = Fetcher.grouse_tickets(Date.today)

  now = Time.now
  firestore.col('ujihisa-test').add({
    time: now,
    grouse: grouse,
    grouse_tickets: grouse_tickets,
  })

  {
    time: now.iso8601,
    grouse: grouse,
    grouse_tickets: grouse_tickets,
  }.to_json
end
