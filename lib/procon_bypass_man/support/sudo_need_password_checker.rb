class SudoNeedPasswordChecker
  # @return [boolean] falseならパスワードが必要
  def self.execute!
    system('sudo -n true 2>/dev/null')
  end
end
