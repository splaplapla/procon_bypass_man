require "erb"

enable_integration_with_pbm_cloud = !!@enable_integration_with_pbm_cloud

erb = File.read("./project_template/app.rb.erb")
app_rb = ERB.new(erb, trim_mode: '-').result(binding)

File.write("./project_template/app.rb", app_rb)
