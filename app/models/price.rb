class Price < ActiveRecord::Base
  belongs_to :projection
  
  def line
    Line.where(sport: self.sport, date: self.date.to_date.to_time, team1: self.team).take
  end
  
  
end
