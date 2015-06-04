require 'rails_helper'

RSpec.describe "projections/show", type: :view do
  before(:each) do
    @projection = assign(:projection, Projection.create!(
      :player => "Player",
      :fpts => "9.99",
      :team => "Team",
      :opponent => "Opponent",
      :position => "Position",
      :cost => 1,
      :source => "Source",
      :site => "Site",
      :sport => "Sport"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Player/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/Opponent/)
    expect(rendered).to match(/Position/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Source/)
    expect(rendered).to match(/Site/)
    expect(rendered).to match(/Sport/)
  end
end
