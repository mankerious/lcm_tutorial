service_project = @client.create_project(title: 'Service project', auth_token: TOKEN)

downloader_process = redeploy_or_create_process(service_project, "./scripts/#{VERSION}/service/downloader", name: 'downloader', type: :ruby)
downloader_schedule = redeploy_or_create_schedule(downloader_process, '0 * * * *', 'main.rb', {
  name: 'downloader'
})

transform_process = redeploy_or_create_process(service_project, "./scripts/#{VERSION}/service/transform", name: 'transform', type: :ruby)
transform_schedule = redeploy_or_create_schedule(transform_process, downloader_schedule, 'main.rb', {
  name: 'transform'
})

# association_process = redeploy_or_create_process(service_project, 'appstore://segments_workspace_association_brick', name: 'association', type: :ruby)
association_process = redeploy_or_create_process(service_project, './scripts/apps/segments_workspace_association_brick', name: 'association', type: :ruby)
association_schedule = redeploy_or_create_schedule(association_process, transform_schedule, 'main.rb', {
  name: 'association',
  params: {
    organization: DOMAIN,
    input_source: "association.csv",
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: HOSTNAME
  }
})

provisioning_process = redeploy_or_create_process(service_project, './scripts/apps/segment_provisioning_brick', name: 'provision', type: :ruby)
provisioning_schedule = redeploy_or_create_schedule(provisioning_process, association_schedule, 'main.rb', {
  name: 'provision',
  params: {
    organization: DOMAIN,
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: HOSTNAME
  }
})

users_process = redeploy_or_create_process(service_project, 'appstore://users_brick', name: 'users', type: :ruby)
users_schedule = redeploy_or_create_schedule(users_process, provisioning_schedule, 'main.rb', {
  name: 'users',
  params: {
    organization: DOMAIN,
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: HOSTNAME,
    mode: 'add_to_organization',
    input_source: 'users.csv'
  }
})

puts "Service master project PID is #{service_project.pid}"