#!/usr/bin/env ruby

require 'curb'
require 'json'
require 'time'

# Get the ID of the escalation policy associated with the service
url = "https://api.pagerduty.com/services/#{ARGV[1]}"

http = Curl.get(url) do |curl|
  curl.headers['Content-type'] = 'application/json'
  curl.headers['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
  curl.headers['Accept'] = 'application/vnd.pagerduty+json;version=2'
end

if http.response_code == 200
  result = JSON.parse(http.body_str)
  escalation_policy_id = result['service']['escalation_policy']['id']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the currently on-call user
url = 'https://api.pagerduty.com/oncalls'
params = { 'since' => Time.now.utc.iso8601,
           'until' => (Time.now.utc + 60).iso8601,
           'escalation_policy_ids[]' => escalation_policy_id }

Curl.postalize(params)

url = Curl.urlalize(url, params)

http = Curl.get(url) do |curl|
  curl.headers['Content-type'] = 'application/json'
  curl.headers['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
  curl.headers['Accept'] = 'application/vnd.pagerduty+json;version=2'
end

if http.response_code == 200
  result = JSON.parse(http.body_str)
  user_id = result['oncalls'][0]['user']['id']
  user_name = result['oncalls'][0]['user']['summary']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the contact information of the userid
url = "https://api.pagerduty.com/users/#{user_id}/contact_methods"

http = Curl.get(url) do |curl|
  curl.headers['Content-type'] = 'application/json'
  curl.headers['Authorization'] = "Token token=#{ARGV[0]}" # read/only api token
  curl.headers['Accept'] = 'application/vnd.pagerduty+json;version=2'
end

if http.response_code == 200
  result = JSON.parse(http.body_str)
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
