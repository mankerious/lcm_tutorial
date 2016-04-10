require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'stuff'
require_relative 'credentials'

client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
domain = client.domain(DOMAIN)

service_project = client.projects(ARGV.first)

tempfile = Tempfile.new('association.csv')
headers = [:segment_id, :client_id]
CSV.open(tempfile.path, 'w') do |csv|
  csv << headers
  csv << ['basic_segment', 'acme']
  csv << ['basic_segment', 'hearst']
  csv << ['basic_segment', 'mastercard']
  csv << ['basic_segment', 'level_up']
end
service_project.upload_file(tempfile.path, :filename => 'association.csv')
tempfile.delete

tempfile = Tempfile.new('users.csv')
headers = [:login, :first_name, :last_name]
CSV.open(tempfile.path, 'w') do |csv|
  csv << headers
  csv << ['john@mustangs.com', 'John', 'Doe']
  csv << ['jane@mustangs.com', 'Jane', 'Doe']
end
service_project.upload_file(tempfile.path, :filename => 'users.csv')
tempfile.delete

