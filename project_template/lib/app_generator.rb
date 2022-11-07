require "erb"

# NOTE pbmenvで参照しているクラス
# 後方互換を維持するために、パラメータの削除・必須をしてはいけない
class AppGenerator
  attr_reader :prefix_path

  # @param [String] prefix_path
  # @param [Boolean] enable_integration_with_pbm_cloud
  def initialize(prefix_path: , enable_integration_with_pbm_cloud: )
    @prefix_path = prefix_path
    @enable_integration_with_pbm_cloud = enable_integration_with_pbm_cloud
  end

  def generate
    erb = File.read(template_path)
    enable_integration_with_pbm_cloud = @enable_integration_with_pbm_cloud
    app_rb = ERB.new(erb, trim_mode: '-').result(binding)
    File.write(output_path, app_rb)
  end

  private

  def template_path
    File.join(prefix_path, "app.rb.erb")
  end

  def output_path
    File.join(prefix_path, "app.rb")
  end
end
