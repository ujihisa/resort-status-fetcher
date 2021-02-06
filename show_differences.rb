# let b:quickrun_config = {'exec': 'doo -b bundle exec ruby show_differences.rb'}
require 'google/cloud/firestore'

def show_differences
  firestore = ::Google::Cloud::Firestore.new(
    project_id: 'devs-sandbox',
    credentials: 'devs-sandbox-5941dd8999bb.json')

  col = firestore.col('ujihisa-test')
  col.get.sort_by { _1[:time] }.map {|x|
    [x[:time], eval(x[:grouse][:runs]).to_set]
  }.each_cons(2) {|(x_time, x_runs), (y_time, y_runs)|
    pp [y_time, x_runs - y_runs, y_runs - x_runs] if x_runs != y_runs
  }
end

def show_after(time)
  firestore = ::Google::Cloud::Firestore.new(
    project_id: 'devs-sandbox',
    credentials: 'devs-sandbox-5941dd8999bb.json')

  col = firestore.col('ujihisa-test')
  after = col.get.sort_by { _1[:time] }.detect { time < _1[:time] }
  p after[:time]
  after[:grouse].each do |name, str|
    puts '--------------------'
    p name
    pp JSON.parse(str)
  end
end

def show_all
  firestore = ::Google::Cloud::Firestore.new(
    project_id: 'devs-sandbox',
    credentials: 'devs-sandbox-5941dd8999bb.json')

  col = firestore.col('ujihisa-test')
  col.get.select { _1[:grouse_tickets] }.sort_by { _1[:time] }.each do |x|
    p x[:time]
    pp x[:grouse_tickets].sort_by(&:first)
  end
end

# show_differences()
# show_after(Time.parse('2021-01-27T12:32:02-08:00'))
show_all()
