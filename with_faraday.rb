#!/usr/bin/env ruby

require 'faraday'
require 'json'
require 'time'

# Get the escalation_policy_id from the service
conn = Faraday.new('url' => 'https://api.pagerduty.com/') do |faraday|
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
  faraday.headers['Content-type'] = 'application/json'
  faraday.headers['Authorization'] = "Token token=#{ARGV[0]}"
  faraday.headers['Accept'] = 'application/vnd.pagerduty+json;version=2'
end

response = conn.get "/services/#{ARGV[1]}"
if response.status == 200
  result = JSON.parse(response.body)
  escalation_policy_id = result['service']['escalation_policy']['id']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the currently on-call user
conn = Faraday.new('url' => 'https://api.pagerduty.com') do |faraday|
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
  faraday.headers['Content-type'] = 'application/json'
  faraday.headers['Authorization'] = "Token token=#{ARGV[0]}"
  faraday.headers['Accept'] = 'application/vnd.pagerduty+json;version=2'
  faraday.params['since'] = Time.now.utc.iso8601
  faraday.params['until'] = (Time.now.utc + 60).iso8601
  faraday.params['escalation_policy_ids[]'] = escalation_policy_id
end

response = conn.get '/oncalls'
if response.status == 200
  result = JSON.parse(response.body)
  user_id = result['oncalls'][0]['user']['id']
  user_name = result['oncalls'][0]['user']['summary']
else
  puts 'Oh snap! Something went wrong.'
end

# Get the contact information of the user
conn = Faraday.new('url' => 'https://api.pagerduty.com') do |faraday|
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
  faraday.headers['Content-type'] = 'application/json'
  faraday.headers['Authorization'] = "Token token=#{ARGV[0]}"
end

response = conn.get "/users/#{user_id}/contact_methods"
if response.status == 200
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
