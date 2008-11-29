ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :date => "%Y-%m-%d",
  :hour => "%H",
  :minute => "%M",
  :hours  => "%H:%M",
  :with_minutes => "%Y-%m-%d %H:%M"
)