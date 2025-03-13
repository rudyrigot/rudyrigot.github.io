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

# Reorganize the data in the JSON file so it's easiest to template: hash whose key is the date, and all displayed data are values
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
last_date = events.keys.max

# Insert birthdays
birth_date = Date.parse(json['birth']['date'])
current_birthday = birth_date.next_year
age = 1
while current_birthday <= last_date
    events[current_birthday] = {
        category_symbol: '🎂',
        shorttext: "Turned #{age}",
        longtext: 'Happy birthday to me!'
    }
    current_birthday = current_birthday.next_year
    age += 1
end

# Now let's iterate through time to build all the weeks one by one
week_start_date = Date.parse(json['birth']['date'])
while week_start_date <= last_date
    week_end_date = week_start_date + 6

    # Find if there is an event to represent that week
    event_dates_of_the_week = events.keys.select { |date| date >= week_start_date && date <= week_end_date }
    if event_dates_of_the_week.size > 1
        raise "Oh noes, 2 events in the same week, can't do that! #{events_of_the_week}"
    end

    # Prepare fields to be templated
    if week_start_date == birth_date # Birth!
        shorttext = "#{json['birth']['symbol']} #{json['birth']['shorttext']}"
        longtext = "#{format_date(json['birth']['date'], true)} <div class=\"description\">#{json['birth']['longtext']}</div>"
    elsif event_dates_of_the_week.size > 0
        event_date = event_dates_of_the_week[0]
        event = events[event_date]
        shorttext = "#{event[:category_symbol]} #{event[:shorttext]}"
        longtext = "#{format_date(event_date)} <div class=\"description\">#{event[:longtext]}</div>"
    else
        shorttext = '&nbsp;'
        longtext = "From #{format_date(week_start_date)} to #{format_date(week_end_date)}"
    end

    # Templating
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

# Now insert the fragment where it should be
File.write('index.html', html.gsub('{{my_weeks}}', html_my_weeks.string))

puts 'Done.'