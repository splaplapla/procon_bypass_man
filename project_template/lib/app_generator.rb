require "erb"

class AppGenerator
  attr_reader :prefix_path

  def initialize(prefix_path: , enable_integration_with_pbm_cloud: )
    @prefix_path = prefix_path
    @enable_integration_with_pbm_cloud = enable_integration_with_pbm_cloud
  end

  def generate
    erb = File.read(template_path)
    enable_integration_with_pbm_cloud = @enable_integration_with_pbm_cloud
    app_rb = ERB.new(erb, trim_mode: '-').result(binding)
    File.write(output_path, app_rb)

    puts "Created project_template/app.rb"
  end

  private

  def template_path
    File.join(prefix_path, "app.rb.erb")
  end

  def output_path
    File.join(prefix_path, "app.rb")
  end
end
