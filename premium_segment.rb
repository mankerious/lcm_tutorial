
blueprint = GoodData::Model::ProjectBlueprint.build("Premium Segment #{VERSION}") do |p|
  p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
    d.add_anchor('attr.departments.id', title: 'Department ID')
    d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
    d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
    d.add_attribute('attr.departments.region', title: 'Department Region')
    d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
  end
end

premium_master_project = @client.create_project_from_blueprint(blueprint, auth_token: TOKEN)

load_process = redeploy_or_create_process(premium_master_project, "./scripts/#{VERSION}/premium/load", name: 'load', type: :ruby)
load_schedule = redeploy_or_create_schedule(load_process, '0 * * * *', 'main.rb', {
  name: 'load'
})
load_schedule.disable!

filters_process = redeploy_or_create_process(premium_master_project, 'appstore://user_filters_brick', {})
filters_schedule = redeploy_or_create_schedule(filters_process, load_schedule, 'main.rb', {
  name: 'filters',
  params: {
    input_source: "filters.csv",
    sync_mode: "sync_one_project_based_on_custom_id",
    organization: DOMAIN,
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: HOSTNAME,
    filters_config: {
      user_column: "login",
      labels: [{label: "label.departments.id", "column": "department"}]
    }
  }
})
filters_schedule.disable!

add_users_process = redeploy_or_create_process(premium_master_project, 'appstore://users_brick', {})
add_users_schedule = redeploy_or_create_schedule(add_users_process, filters_schedule, 'main.rb', {
  name: 'users',
  params: {
    input_source: "users.csv",
    sync_mode: "sync_one_project_based_on_custom_id",
    organization: DOMAIN,
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: HOSTNAME
  }
})
add_users_schedule.disable!

service_segment = create_or_get_segment(@domain, 'premium_segment', premium_master_project, version: VERSION)
