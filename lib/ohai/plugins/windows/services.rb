Ohai.plugin(:Services) do
  
  require 'ruby-wmi'

  provides 'services'
  collect_data(:windows) do
    services Mash.new
    svc = WMI::Win32_Service.find(:all)

    svc.each do |service|
      services[service.name] = Mash.new
      %w(name displayname pathname servicetype processid startname started startmode).each do |attrib|
        services[service.name][attrib] = service.send(attrib)
      end
    end
  end
  
end