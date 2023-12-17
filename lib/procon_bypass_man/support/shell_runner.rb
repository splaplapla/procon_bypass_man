class ShellRunner
  # @param [String] command
  # @param [Boolean] stdout
  # @return [void]
  def self.execute(command, stdout: true)
    system(command) # TODO: ここでエラーが起きたときに、エラーをログに出力する
    if stdout
      ProconBypassMan.logger.info("[SHELL]: #{command}")
    end
  end
end
