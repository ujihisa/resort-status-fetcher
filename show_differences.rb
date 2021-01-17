# let b:quickrun_config = {'exec': 'doo bundle exec ruby show_differences.rb'}
require 'google/cloud/firestore'

firestore = ::Google::Cloud::Firestore.new(
  project_id: 'devs-sandbox',
  credentials: 'devs-sandbox-5941dd8999bb.json')

col = firestore.col('ujihisa-test')
col.get.sort_by { _1[:time] }.map {|x|
  [x[:time], eval(x[:grouse][:runs]).to_set]
}.each_cons(2) {|(x_time, x_runs), (y_time, y_runs)|
  pp [y_time, x_runs - y_runs, y_runs - x_runs] if x_runs != y_runs
}
