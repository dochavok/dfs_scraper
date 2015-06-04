json.array!(@projections) do |projection|
  json.extract! projection, :id, :date, :player, :fpts, :team, :opponent, :position, :cost, :source, :site, :sport
  json.url projection_url(projection, format: :json)
end
