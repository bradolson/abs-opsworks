node[:deploy].each do |application, deploy|

  Chef::Log.info("Writing monit configs for resque jobs")

  deploy[:monit][:resque][:workers].times do |x|
    template "/etc/monit/conf.d/#{application}.worker.monitrc" do
      source 'monit.worker.erb'
      mode '0440'
      owner 'root'
      group 'root'
      variables({
        :idx => x,
        :rails_env => deploy[:rails_env],
        :app_name => application
      })
      notifies :reload, 'service[monit]'
    end
  end

  Chef::Log.info("Writing monit config for resque scheduler")

  template "/etc/monit/conf.d/#{application}.scheduler.monitrc" do
    source 'monit.scheduler.erb'
    mode '0440'
    owner 'root'
    group 'root'
    variables({
      :rails_env => deploy[:rails_env],
      :app_name => application
    })
    notifies :reload, 'service[monit]'
    only_if { deploy[:monit][:resque][:scheduler] }
  end

  include_recipe "opsworks_monit_resque::restart"
end