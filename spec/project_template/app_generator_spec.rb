require "spec_helper"
require "./project_template/lib/app_generator"

describe AppGenerator do
  let(:tmp_app_path) { "./tmp/app.rb" }
  before do
    FileUtils.cp("./project_template/app.rb.erb", "tmp")
    FileUtils.rm_rf(tmp_app_path)
  end

  it do
    expect(File.exist?(tmp_app_path)).to eq(false)
    described_class.new(
      prefix_path: "./tmp",
      enable_integration_with_pbm_cloud: true
    ).generate
    expect(File.exist?(tmp_app_path)).to eq(true)
  end
end
