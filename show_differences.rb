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

def dump_tickets_tsv
  firestore = ::Google::Cloud::Firestore.new(
    project_id: 'devs-sandbox',
    credentials: 'devs-sandbox-5941dd8999bb.json')

  col = firestore.col('ujihisa-test')
  data = col.get.select { _1[:grouse_tickets] }

  all_dates = data.flat_map { _1[:grouse_tickets].keys }.uniq.sort
  quantities_by_time = data.sort_by { _1[:time] }.map {|x|
    [
      x[:time].localtime(Time.zone_offset('PST')),
      *all_dates.map {|date| x[:grouse_tickets][date] }
    ]
  }

  # header
  puts ['time', *all_dates].join("\t")
  # body
  quantities_by_time.each do |line|
    puts line.join("\t")
  end
end

def chart_tickets
  require 'set'
  require 'date'
  holidays = %i[2021-02-02 2021-02-15].to_set.freeze

  firestore = ::Google::Cloud::Firestore.new(
    project_id: 'devs-sandbox',
    credentials: 'devs-sandbox-5941dd8999bb.json')

  col = firestore.col('ujihisa-test')
  data = col.order(:time, :desc).get.select { _1[:grouse_tickets] }

  dates = data.flat_map { _1[:grouse_tickets].keys }.uniq.sort
  hash = dates.group_by { holidays.member?(_1) ? 'Holiday' : Date.parse(_1.name).strftime('%A') }
  hash = hash.transform_values {|dates|
    dates.map {|date|
      data.map {|x| x[:grouse_tickets]&.[](date) }.compact
    }
  }

  matrix = hash.flat_map {|day, ticketss|
    ticketss.map {|tickets|
      [day, *tickets]
    }
  }

  matrix.each do |xs|
    puts xs.join("\t")
  end
end

# show_differences()
# show_after(Time.parse('2021-02-08T09:02:02-08:00'))
chart_tickets()
