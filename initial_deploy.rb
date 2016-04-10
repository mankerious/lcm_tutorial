require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative 'stuff'
require_relative 'credentials'

@client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
# GoodData.logging_http_on
@domain = @client.domain(DOMAIN)
VERSION = '1.0.0'

#########
# BASIC #
#########

require_relative 'basic_segment'

###########
# PREMIUM #
###########

require_relative 'premium_segment'

###########
# RELEASE #
###########

@domain.synchronize_clients
@domain.provision_client_projects

# DONE
puts HighLine.color('DONE', :green)
