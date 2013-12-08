require 'net/https'
require 'json'
require 'time'

# Get the userid of person from the rendered schedule 
schedule_url = URI.parse "https://yourdomain.pagerduty.com/api/v1/schedules/#{ARGV[1]}"
http = Net::HTTP.new schedule_url.host, schedule_url.port
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.use_ssl = true
 
schedule_params = { :since => Time.now.utc.iso8601(), 
                    :until => (Time.now.utc + 60).iso8601() }

schedule_url.query = URI.encode_www_form(schedule_params)
 
request = Net::HTTP::Get.new(schedule_url.request_uri)
request["Content-type"] = "application/json"
request["Authorization"] = "Token token=#{ARGV[0]}"  # read/only api token
 
schedule_response = http.request(request)
 
if schedule_response.code == "200"
  schedule_result = JSON.parse(schedule_response.body)
  user_id = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["id"]
  user_name = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["name"]
else
  puts "Oh snap! Something went wrong."
end
 
# Get the contact information of the userid 
user_url = URI.parse "https://yourdomain.pagerduty.com/api/v1/users/#{user_id}/contact_methods"
http = Net::HTTP.new user_url.host, user_url.port
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.use_ssl = true
 
request = Net::HTTP::Get.new(user_url.request_uri)
request["Content-type"] = "application/json"
request["Authorization"] = "Token token=#{ARGV[0]}"  # read/only api token
 
user_response = http.request(request)
 
if user_response.code == "200"
  user_result = JSON.parse(user_response.body)
  user_email = user_result["contact_methods"][0]["email"]
  user_phone = user_result["contact_methods"][1]["phone_number"]
else
  puts "Oh snap! Something went wrong."
end
 
# Print out the On-Call User information
puts "On-Call Engineer: #{user_name} - #{user_email} - #{user_phone}"
