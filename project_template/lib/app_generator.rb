require "erb"

class AppGenerator
  attr_reader :path

  def initialize(path: , enable_integration_with_pbm_cloud: )
    @path = path
    @enable_integration_with_pbm_cloud = enable_integration_with_pbm_cloud
  end

  def generate
    erb = File.read(File.join(path, template_path))
    enable_integration_with_pbm_cloud = @enable_integration_with_pbm_cloud
    app_rb = ERB.new(erb, trim_mode: '-').result(binding)
    File.write(File.join(path, output_path), app_rb)
  end

  private

  def template_path
    "project_template/app.rb.erb"
  end

  def output_path
    "project_template/app.rb"
  end
end
