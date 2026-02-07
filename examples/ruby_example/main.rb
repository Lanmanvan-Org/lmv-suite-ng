#!/usr/bin/env ruby
# Ruby Example Module
# Educational module demonstrating Ruby capabilities
# Author: LanManVan Team

# Get arguments from environment variables
text = ENV['ARG_TEXT']
action = ENV['ARG_ACTION'] || 'count'

if !text || text.empty?
  puts "[!] Error: TEXT is required"
  exit 1
end

puts
puts "[*] Ruby Example Module"
puts "[*] Text: #{text}"
puts "[*] Action: #{action}"
puts

begin
  case action.downcase
  when 'count'
    # Count characters, words, and lines
    char_count = text.length
    word_count = text.split.length
    line_count = text.lines.length
    
    puts "[*] Text Analysis:"
    puts "[+] Characters: #{char_count}"
    puts "[+] Words: #{word_count}"
    puts "[+] Lines: #{line_count}"
    
  when 'reverse'
    # Reverse the text
    reversed = text.reverse
    puts "[*] Original: #{text}"
    puts "[+] Reversed: #{reversed}"
    
  when 'uppercase'
    # Convert to uppercase
    upper = text.upcase
    puts "[*] Original: #{text}"
    puts "[+] Uppercase: #{upper}"
    
  when 'find_emails'
    # Find email addresses using regex
    email_pattern = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/
    emails = text.scan(email_pattern)
    
    if emails.empty?
      puts "[-] No email addresses found"
    else
      puts "[+] Found #{emails.length} email address(es):"
      emails.each { |email| puts "[+]   #{email}" }
    end
    
  when 'unique_words'
    # Extract unique words
    words = text.split.map(&:downcase).uniq
    puts "[+] Found #{words.length} unique word(s):"
    words.each { |word| puts "[+]   #{word}" }
    
  else
    puts "[!] Unknown action: #{action}"
    puts "[*] Available actions: count, reverse, uppercase, find_emails, unique_words"
    exit 1
  end
  
  puts
  puts "[+] Ruby module execution completed successfully!"
  puts

rescue => e
  puts "[!] Error: #{e.class}: #{e.message}"
  exit 1
end
