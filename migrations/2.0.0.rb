require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative '../stuff'
require_relative '../credentials'

client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
domain = client.domain(DOMAIN)
service_project = client.projects(ARGV.first)


release(domain, '2.0.0', auth_token: TOKEN, service_project: service_project) do |release|
  release.with_segment('basic_segment') do |segment, new_master_project|
    blueprint = new_master_project.blueprint
    blueprint.datasets('dataset.departments').change do |d|
      d.add_fact('fact.departments.number', title: 'NUMBER')
    end
    new_master_project.update_from_blueprint(blueprint)
    redeploy_or_create_process(new_master_project, './scripts/load/2.0.0', name: 'load')
  end
  release.with_project(service_project) do |new_project|
    new_project
  end
end
