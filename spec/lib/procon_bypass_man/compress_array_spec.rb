require "spec_helper"

describe ProconBypassMan::CompressArray do
  it do
    actual = ProconBypassMan::CompressArray.new([
      "a",
      "b",
      "b",
      "b",
      "b",
      "c",
      "d",
      "d",
      "d",
      "d",
    ]).compress
    expect(actual).to eq(["a", "b * 3", "c", "d * 3"])
  end

  it do
    actual = ProconBypassMan::CompressArray.new([
      "a",
      "b",
      "b",
      "read_from(switch): IO::EAGAINWaitReadable",
      "read_from(switch): IO::EAGAINWaitReadable",
      "read_from(switch): IO::EAGAINWaitReadable",
      "b",
      "b",
      "c",
      "d",
      "d",
      "d",
      "d",
    ]).compress
    expect(actual).to eq(["a", "b * 1", "read_from(switch): IO::EAGAINWaitReadable * 4", "c", "d * 3"])
  end
end
