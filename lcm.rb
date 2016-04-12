
require 'gooddata'
require 'bundler/setup'
require 'goodot'
require 'sinatra'
require 'slim'
require 'sinatra/base'
require 'active_support/all'
require_relative 'stuff'
require_relative 'credentials'
require 'pp'


  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end


SERVICE_PID = 'g5wic4ho9fs7rjtllen4vhudm0jur9ax'
  
get '/' do 

  slim :index 
end


get '/settings' do


    slim :settings
end

post '/settings' do

    VERSION = '1.0.0'
    blueprint = GoodData::Model::ProjectBlueprint.build("#{params[:basic_master_name]} #{VERSION}") do |p|
      p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
        d.add_anchor('attr.departments.id', title: 'Department ID')
        d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
        d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
        d.add_attribute('attr.departments.region', title: 'Department Region')
        d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
      end
    end


    @client = GoodData.connect('mustang@gooddata.com', 'jindrisska', server: 'https://mustangs.intgdc.com', verify_ssl: false )
    @domain = @client.domain(DOMAIN)
    basic_master_project = @client.create_project_from_blueprint(blueprint, auth_token: TOKEN)

    # load_process = redeploy_or_create_process(basic_master_project, './scripts/1.0.0/basic/load', name: 'load', type: :ruby)
    # load_schedule = redeploy_or_create_schedule(load_process, '0 * * * *', 'main.rb', {
    #   name: 'load',
    #   params: {
    #     CLIENT_GDC_PROTOCOL: 'https',
    #     CLIENT_GDC_HOSTNAME: HOSTNAME,
    #   }
    # })
    # load_schedule.disable!

    # filters_process = redeploy_or_create_process(basic_master_project, 'appstore://user_filters_brick', {})
    # filters_schedule = redeploy_or_create_schedule(filters_process, load_schedule, 'main.rb', {
    #   name: 'filters',
    #   params: {
    #     input_source: "filters.csv",
    #     sync_mode: "sync_one_project_based_on_custom_id",
    #     organization: DOMAIN,
    #     CLIENT_GDC_PROTOCOL: 'https',
    #     CLIENT_GDC_HOSTNAME: HOSTNAME,
    #     filters_config: {
    #       user_column: "login",
    #       labels: [{label: "label.departments.name", "column": "department"}]
    #     }
    #   }
    # })
    # filters_schedule.disable!

    # add_users_process = redeploy_or_create_process(basic_master_project, 'appstore://users_brick', {})
    # add_users_schedule = redeploy_or_create_schedule(add_users_process, filters_schedule, 'main.rb', {
    #   name: 'users',
    #   params: {
    #     input_source: "users.csv",
    #     sync_mode: "sync_one_project_based_on_custom_id",
    #     organization: DOMAIN,
    #     CLIENT_GDC_PROTOCOL: 'https',
    #     CLIENT_GDC_HOSTNAME: HOSTNAME
    #   }
    # })
    # add_users_schedule.disable!

    service_segment = create_or_get_segment(@domain, params[:basic_segment_name], basic_master_project, version: VERSION)

    blueprint = GoodData::Model::ProjectBlueprint.build("#{params[:premium_master_name]} #{VERSION}") do |p|
      p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
        d.add_anchor('attr.departments.id', title: 'Department ID')
        d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
        d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
        d.add_attribute('attr.departments.region', title: 'Department Region')
        d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
      end
      p.add_dataset('dataset.employees', title: 'Employee', folder: 'Department & Employee') do |d|
        d.add_anchor('attr.employees.id', title: 'Employee ID')
        d.add_label('label.employees.id', reference:'attr.employees.id', title: 'Employee ID')
        d.add_label('label.employees.name', reference: 'attr.employees.id', title: 'Employee Name')
        d.add_attribute('attr.employees.region', title: 'Employee Region')
        d.add_label('label.employees.region', reference: 'attr.employees.region', title: 'Employee Region')
      end
    end


    @client = GoodData.connect('mustang@gooddata.com', 'jindrisska', server: 'https://mustangs.intgdc.com', verify_ssl: false )
    @domain = @client.domain(DOMAIN)
    premium_master_project = @client.create_project_from_blueprint(blueprint, auth_token: TOKEN)
    service_segment = create_or_get_segment(@domain, params[:premium_segment_name], premium_master_project, version: VERSION)

      slim :initial_deploy
end

post '/index' do


   client = GoodData.connect('mustang@gooddata.com', 'jindrisska', server: 'https://mustangs.intgdc.com', verify_ssl: false )
   @version='1.0.0'
   @domain=client.domain('mustangs')
   @project_pid = params[:projectid]
   @master_project = client.projects(@project_pid)
   @segment_name = params[:segment_name]
   pp @segment_name
   $segment = create_or_get_segment(@domain, @segment_name, @master_project, version: @version)
   set_master_metadata(@master_project, @version, $segment.id)

   slim :segment_details
end

post '/project' do

  	slim :project
end




post '/segment_details' do
   
   @version='1.0.0'
   client = GoodData.connect('mustang@gooddata.com', 'jindrisska', server: 'https://mustangs.intgdc.com', verify_ssl: false )
   @domain=client.domain('mustangs')
   # master_project = client.projects($project_pid)
   # @domain.remove_segment($segment_name)
   pp $segment.id
   create_or_get_client($segment, "acme_client1")
   @domain.synchronize_clients
   @domain.provision_client_projects

    slim :segment_details
end




post '/segments' do
   
   @version='1.0.0'
   client = GoodData.connect('mustang@gooddata.com', 'jindrisska', server: 'https://mustangs.intgdc.com', verify_ssl: false )
   @domain=client.domain('mustangs')
   basic_master_project = client.projects(@project_pid)
   $segment_name=params[:segment_name]
   @service_segment = create_or_get_segment(@domain, $segment_name, basic_master_project, version: @version)
   $segment_id = @service_segment.id

    slim :segment_details
end

get '/initial_deploy' do

    slim :initial_deploy
end

post '/initial_deploy' do
    @client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
    # GoodData.logging_http_on
    @domain = @client.domain(DOMAIN)
    VERSION = '1.0.0'


    ###########
    # RELEASE #
    ###########

    @domain.synchronize_clients
    @domain.provision_client_projects

    # DONE
    puts HighLine.color('DONE', :green)


    slim :initial_deploy
end

get '/service_project' do

    slim :service_project
end

post '/service_project' do

    @client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
    # GoodData.logging_http_on
    @domain = @client.domain(DOMAIN)
    VERSION = '1.0.0'

    ###########
    # SERVICE #
    ###########

service_project = @client.create_project(title: 'zulu service project', auth_token: TOKEN)

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

# users_process = redeploy_or_create_process(service_project, 'appstore://users_brick', name: 'users', type: :ruby)
# users_schedule = redeploy_or_create_schedule(users_process, provisioning_schedule, 'main.rb', {
#   name: 'users',
#   params: {
#     organization: DOMAIN,
#     CLIENT_GDC_PROTOCOL: 'https',
#     CLIENT_GDC_HOSTNAME: HOSTNAME,
#     mode: 'add_to_organization',
#     input_source: 'users.csv'
#   }
# })

puts "Service master project PID is #{service_project.pid}"

    # DONE
    puts HighLine.color('DONE', :green)


    slim :service_project
end


get '/service_data_load' do

    slim :service_data_load
end

post '/service_data_load' do

    client = GoodData.connect(LOGIN, PASSWORD, server: FQDN, verify_ssl: false )
    domain = client.domain(DOMAIN)

    service_project = client.projects(SERVICE_PID)

    tempfile = Tempfile.new('association.csv')
    headers = [:segment_id, :client_id]
    CSV.open(tempfile.path, 'w') do |csv|
      csv << headers
      csv << ['zulu_basic', 'zulu1']
      csv << ['zulu_basic', 'zulu2']
    end
    service_project.upload_file(tempfile.path, :filename => 'association.csv')
    tempfile.delete

    # tempfile = Tempfile.new('users.csv')
    # headers = [:login, :first_name, :last_name]
    # CSV.open(tempfile.path, 'w') do |csv|
    #   csv << headers
    #   csv << ['john@mustangs.com', 'John', 'Doe']
    #   csv << ['jane@mustangs.com', 'Jane', 'Doe']
    # end
    # service_project.upload_file(tempfile.path, :filename => 'users.csv')
    # tempfile.delete

    # DONE
    pp service_project.pid
    puts HighLine.color('DONE', :green)

    slim :service_data_load
end
