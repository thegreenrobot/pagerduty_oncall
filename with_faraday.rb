require 'faraday'
require 'json'
require 'time'

# Get the userid of person from the rendered schedule 
conn = Faraday.new(:url => 'https://yourdomain.pagerduty.com') do |faraday|
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
  faraday.headers['Content-type'] = 'application/json'
  faraday.headers['Authorization'] = "Token token=#{ARGV[0]}"
  faraday.params['since'] = Time.now.utc.iso8601()
  faraday.params['until'] = (Time.now.utc + 60).iso8601()
end

response = conn.get "/api/v1/schedules/#{ARGV[1]}"
if response.status == 200
  schedule_result = JSON.parse(response.body)
  user_id = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["id"]
  user_name = schedule_result["schedule"]["schedule_layers"][0]["rendered_schedule_entries"][0]["user"]["name"]
else
  puts "Oh snap! Something went wrong."
end

# Get the contact information of the userid  
conn = Faraday.new(:url => 'https://yourdomain.pagerduty.com') do |faraday|
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
  faraday.headers['Content-type'] = 'application/json'
  faraday.headers['Authorization'] = "Token token=#{ARGV[0]}"
end

response = conn.get "/api/v1/users/#{user_id}/contact_methods"
if response.status == 200
  user_result = JSON.parse(response.body)
  user_email = user_result["contact_methods"][0]["email"]
  user_phone = user_result["contact_methods"][1]["phone_number"]
else
  puts "Oh snap! Something went wrong."
end
 
# Print out the On-Call User information
puts "On-Call Engineer: #{user_name} - #{user_email} - #{user_phone}"
