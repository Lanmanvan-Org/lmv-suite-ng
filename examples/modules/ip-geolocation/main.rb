#!/usr/bin/env ruby

##############################################################################
# IP Geolocation Module - Ruby
# Get geolocation information for an IP address using the ip-api.com API
# Author: LanManVan Team
##############################################################################

require 'net/http'
require 'uri'
require 'json'
require 'ipaddr'

# Color codes
RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

def get_env_var(name, default = nil)
  ENV["ARG_#{name.upcase}"] || default
end

def is_valid_ip?(ip)
  begin
    IPAddr.new(ip)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end

def get_geolocation(ip)
  uri = URI("http://ip-api.com/json/#{ip}")
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
rescue => e
  { "status" => "fail", "message" => "Error: #{e.message}" }
end

def print_text_format(data)
  if data["status"] == "fail"
    puts "#{RED}[!]#{NC} Error: #{data['message']}"
    return
  end

  puts
  puts "#{BLUE}[*]#{NC} IP Geolocation Information"
  puts "=" * 50

  fields = {
    "IP Address" => "query",
    "Country" => "country",
    "Country Code" => "countryCode",
    "Region" => "regionName",
    "City" => "city",
    "Latitude" => "lat",
    "Longitude" => "lon",
    "ISP" => "isp",
    "Organization" => "org",
    "AS" => "as",
    "Timezone" => "timezone",
    "Mobile" => "mobile",
    "Proxy" => "proxy",
    "Hosting" => "hosting"
  }

  fields.each do |label, key|
    value = data[key] || "N/A"
    printf "  %-25s %s\n", "#{label}:", value
  end

  puts "=" * 50
  puts
end

def print_json_format(data)
  puts JSON.pretty_generate(data)
end

def print_csv_format(data)
  if data["status"] == "fail"
    puts "Error,#{data['message']}"
    return
  end

  csv_fields = [
    "query", "country", "countryCode", "regionName", "city",
    "lat", "lon", "isp", "org", "as", "timezone", "mobile", "proxy", "hosting"
  ]

  puts csv_fields.join(",")
  values = csv_fields.map { |field| data[field] || "" }
  puts values.join(",")
end

def main
  ip = get_env_var("ip")
  format = get_env_var("format", "text").downcase

  if ip.nil? || ip.empty?
    puts "#{RED}[!]#{NC} Error: IP address is required"
    puts "Usage: ip=<ip_address> [format=text|json|csv]"
    exit 1
  end

  unless is_valid_ip?(ip)
    puts "#{RED}[!]#{NC} Error: '#{ip}' is not a valid IP address"
    exit 1
  end

  unless ["text", "json", "csv"].include?(format)
    puts "#{RED}[!]#{NC} Error: Invalid format '#{format}'. Use: text, json, or csv"
    exit 1
  end

  puts "#{BLUE}[*]#{NC} Fetching geolocation for #{ip}..."

  data = get_geolocation(ip)

  case format
  when "json"
    print_json_format(data)
  when "csv"
    print_csv_format(data)
  else
    print_text_format(data)
  end
end

main if __FILE__ == $0
