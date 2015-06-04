json.array!(@prices) do |price|
  json.extract! price, :id, :projection_id, :sport, :date, :position, :team, :player, :salary, :site, :site_id, :salary_cap, :format
  json.url price_url(price, format: :json)
end
