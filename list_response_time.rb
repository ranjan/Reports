require 'date'
require 'fileutils'

if ARGV.empty?
  puts "Enter Search Text for production.log"
  INPUT_TEXT = gets.chomp
else
  INPUT_TEXT = ARGV[0]
end

matched_lines = []
File.foreach("var/log/foreman/production.log") do |line|
  text_match = line.match(INPUT_TEXT)
  next unless text_match
  matched_lines << line
end

RESPONSE_TEXT = "Completed 200 OK in"

matched_lines.each do |line|
  id = line[/\[(.*?)\]/m, 1]
  File.foreach("var/log/foreman/production.log") do |log|
    if log.include?(RESPONSE_TEXT) && log.include?(id)
      print line
      print log
      break
    end
  end
end
