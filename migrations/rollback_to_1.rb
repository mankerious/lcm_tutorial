require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative('../stuff')

LOGIN = ''
PASSWORD = ''
TOKEN = ''
DOMAIN = ''
SERVER = ''

client = GoodData.connect(LOGIN, PASSWORD, server: SERVER, verify_ssl: false )
domain = client.domain(DOMAIN)

revert(domain, '1.0.0', auth_token: TOKEN)