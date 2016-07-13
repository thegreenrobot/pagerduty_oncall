#!/usr/bin/env ruby

require 'net/https'
require 'json'
require 'time'

# Get the escalation_policy_id from the service
url = URI.parse "https://api.pagerduty.com/services/#{ARGV[1]}"
http = Net::HTTP.new url.host, url.port
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.use_ssl = true

request = Net::HTTP::Get.new(url.request_uri)
request['Content-type'] = 'application/json'
request['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
request['Accept'] = 'application/vnd.pagerduty+json;version=2'

response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  escalation_policy_id = result['service']['escalation_policy']['id']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the currently on-call user
url = URI.parse 'https://api.pagerduty.com/oncalls'
http = Net::HTTP.new url.host, url.port
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.use_ssl = true

params = { 'since' => Time.now.utc.iso8601,
           'until' => (Time.now.utc + 60).iso8601,
           'escalation_policy_ids[]' => escalation_policy_id }
url.query = URI.encode_www_form(params)

request = Net::HTTP::Get.new(url.request_uri)
request['Content-type'] = 'application/json'
request['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
request['Accept'] = 'application/vnd.pagerduty+json;version=2'

response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  user_id = result['oncalls'][0]['user']['id']
  user_name = result['oncalls'][0]['user']['summary']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the contact information of the user
url = URI.parse "https://api.pagerduty.com/users/#{user_id}/contact_methods"
http = Net::HTTP.new url.host, url.port
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.use_ssl = true

request = Net::HTTP::Get.new(url.request_uri)
request['Content-type'] = 'application/json'
request['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
request['Accept'] = 'application/vnd.pagerduty+json;version=2'

response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  user_emails = []
  user_phones = []
  result['contact_methods'].each do |method|
    if method['type'] == 'email_contact_method'
      user_emails.push(method['address'])
    elsif method['type'] == 'phone_contact_method'
      user_phones.push(method['address'])
    end
  end
else
  puts 'Oh snap! Something went wrong.'
end

# Print out the On-Call User information
output = "On-Call Engineer: #{user_name}. Email(s): "
if user_emails.any?
  user_emails.each do |email|
    output << email
    output << ', '
  end
  output = output.chomp(', ')
else
  output << 'N/A'
end
output << '. Phone Number(s): '
if user_phones.any?
  user_phones.each do |num|
    output << num
    output << ', '
  end
  output = output.chomp(', ')
else
  output << 'N/A.'
end
puts output
