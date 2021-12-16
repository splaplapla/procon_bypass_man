class ProconBypassMan::Procon::UserOperation
  ::ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.each do |button, _value|
    # UserOperationの動作確認としてこれを定義しておく。本当なら、テスト用のヘルパーを定義したい
    define_method "pressed_#{button}?" do
      pressing_button?(button)
    end
  end
end
