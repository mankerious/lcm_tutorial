require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'stuff'
require_relative 'credentials'

client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
domain = client.domain(DOMAIN)

client_id = ARGV.first
client_project = domain.clients(client_id).project

puts "loading to project #{client_project.pid}"

tempfile = Tempfile.new('filters.csv')
headers = [:pid, :login, :department]
CSV.open(tempfile.path, 'w') do |csv|
  csv << headers
  csv << [client_id, 'john@mustangs.com', 'Sales']
end
client_project.upload_file(tempfile.path, :filename => 'filters.csv')
tempfile.delete

tempfile = Tempfile.new('users.csv')
headers = [:project_id, :login, :role]
CSV.open(tempfile.path, 'w') do |csv|
  csv << headers
  csv << [client_id, 'john@mustangs.com', 'admin']
  csv << [client_id, 'jane@mustangs.com', 'editor']
end
client_project.upload_file(tempfile.path, :filename => 'users.csv')
tempfile.delete

