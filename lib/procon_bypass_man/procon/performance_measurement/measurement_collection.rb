# TODO SpanCollection にする
class  ProconBypassMan::Procon::PerformanceMeasurement::MeasurementCollection
  attr_accessor :timestamp_key, :spans

  def initialize(timestamp_key: , spans: )
    self.timestamp_key = timestamp_key
    self.spans = spans
  end
end
