Ohai.plugin(:Services) do
  
  require 'win32/service'
  include Win32

  provides 'services'
  collect_data(:windows) do
    services Mash.new
    
    svc = Service.services.map{|s| s}

    svc.each do |service|
      services[service.service_name] = Mash.new
      %w(service_name display_name binary_path_name service_type pid start_type current_state delayed_start).each do |attrib|
        services[service.name][attrib] = service.send(attrib)
      end
    end
    
  end
  
end