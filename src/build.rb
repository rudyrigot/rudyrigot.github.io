require 'json'
require 'date'

# Accepts either a string or a date
def format_date(date, long = false)
    date = Date.parse(date) if date.is_a?(String)
    if long
        date.strftime('%B %d %Y')
    else
        date.strftime('%b %d %Y')
    end
end

html = File.read('src/index.html')
html_my_weeks = StringIO.new

json = JSON.parse(File.read('src/weeks.json'))

events = {}

json['categories'].each do | category_name, category_content |
    category_symbol = category_content['symbol']
    category_content['events'].each do | date, texts |
        shorttext = texts['shorttext']
        longtext = texts['longtext']
        raise "The date #{date} is appearing twice, can't do that." if events.key?(Date.parse(date))
        events[Date.parse(date)] = {
            category_symbol: category_symbol,
            shorttext: shorttext,
            longtext: longtext
        }
    end
end

puts JSON.pretty_generate(events)

last_date = events.keys.max
puts "Last date: #{last_date}"

week_start_date = Date.parse(json['birth']['date'])

while week_start_date <= last_date
    week_end_date = week_start_date + 6

    week_name = "From #{format_date(week_start_date)} to #{format_date(week_end_date)}"

    event_dates_of_the_week = events.keys.select { |date| date >= week_start_date && date < week_end_date }
    if event_dates_of_the_week.size > 1
        raise "Oh noes, 2 events in the same week, can't do that! #{events_of_the_week}"
    end

    if week_start_date == Date.parse(json['birth']['date']) # Birth!
        shorttext = "#{json['birth']['symbol']} #{json['birth']['shorttext']}"
        longtext = "#{format_date(json['birth']['date'], true)} <div class=\"description\">#{json['birth']['longtext']}</div>"
    elsif event_dates_of_the_week.size > 0
        event_date = event_dates_of_the_week[0]
        event = events[event_date]
        shorttext = "#{event[:category_symbol]} #{event[:shorttext]}"
        longtext = "#{format_date(event_date)} <div class=\"description\">#{event[:longtext]}</div>"
    else
        shorttext = '&nbsp;'
        longtext = week_name
    end

    html_my_weeks << %{
        <div class="week" data-last-day="#{week_end_date.strftime('%Y-%m-%d')}">
            <div class="shorttext">
                #{shorttext}
            </div>
            <div class="longtext">
                #{longtext}
            </div>
        </div>
    }

    week_start_date += 7
end

File.write('index.html', html.gsub('{{my_weeks}}', html_my_weeks.string))