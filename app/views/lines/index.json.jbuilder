json.array!(@lines) do |line|
  json.extract! line, :id, :date, :team1, :team2, :over_under, :team1_line, :team2_line, :sport, :linetype
  json.url line_url(line, format: :json)
end
