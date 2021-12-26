class ProconBypassMan::SendReloadConfigEventCommand
  # @return [void]
  def self.execute
    ProconBypassMan::PrintMessageCommand.execute(text: "設定ファイルの再読み込みができました")
    ProconBypassMan::ReportReloadConfigJob.perform_async(
      ProconBypassMan.config.raw_setting
    )
  end
end

