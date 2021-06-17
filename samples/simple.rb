ProconBypassMan.run do
  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]

  layer :up, mode: :manual do
    flip :zr, if_pushed: :zr
  end
  layer :right
  layer :left
  layer :down do
    flip :zl
  end
end

