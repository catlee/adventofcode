# Helper for days
class Day
  def self.pad(day)
    '0' + day if day.to_i < 10
    day
  end
end
