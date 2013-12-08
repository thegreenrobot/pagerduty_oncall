require 'curb'
require 'json'
require 'time'
 
# Get the userid of person from the rendered schedule 
schedule_url = "https://yourdomain.pagerduty.com/api/v1/schedules/#{ARGV[1]}"
schedule_params = { :since => Time.now.utc.iso8601(), 
                    :until => (Time.now.utc + 60).iso8601() }
 
Curl::postalize(schedule_params)
 
final_url = Curl::urlalize(schedule_url, schedule_params)
 
http = Curl.get(final_url) do|http|
  http.headers["Content-type"] = "application/json"
  http.headers["Authorization"] = "Token token=#{ARGV[0]}"  # read/only api token
end
 
if http.response_code == 200
  schedule_result = JSON.parse(http.body_str)
  user_id = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["id"]
  user_name = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["name"]
else
  puts "Oh snap! Something went wrong."
end
 
# Get the contact information of the userid  
user_url = "https://yourdomain.pagerduty.com/api/v1/users/#{user_id}/contact_methods"
 
http = Curl.get(user_url) do|http|
  http.headers["Content-type"] = "application/json"
  http.headers["Authorization"] = "Token token=#{ARGV[0]}"  # read/only api token
end
 
if http.response_code == 200
  user_result = JSON.parse(http.body_str)
  user_email = user_result["contact_methods"][0]["email"]
  user_phone = user_result["contact_methods"][1]["phone_number"]
else
  puts "Oh snap! Something went wrong."
end
 
# Print out the On-Call User information
puts "On-Call Engineer: #{user_name} - #{user_email} - #{user_phone}"
