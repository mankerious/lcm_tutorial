require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'stuff'
require_relative 'credentials'

@client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
# GoodData.logging_http_on
@domain = @client.domain(DOMAIN)
VERSION = '1.0.0'

###########
# SERVICE #
###########

require_relative 'service_project'

# DONE
puts HighLine.color('DONE', :green)
