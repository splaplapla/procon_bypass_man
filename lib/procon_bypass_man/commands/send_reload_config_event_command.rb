class ProconBypassMan::SendReloadConfigEventCommand
  # @return [void]
  def self.execute
    puts "設定ファイルの再読み込みができました"
    ProconBypassMan.logger.info "設定ファイルの再読み込みができました"
    ProconBypassMan::ReportReloadConfigJob.perform_async(
      ProconBypassMan.config.raw_setting
    )
  end
end

