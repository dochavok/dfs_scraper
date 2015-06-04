require 'rails_helper'

RSpec.describe "lines/show", type: :view do
  before(:each) do
    @line = assign(:line, Line.create!(
      :team1 => "Team1",
      :team2 => "Team2",
      :over_under => "9.99",
      :team1_line => "9.99",
      :team2_line => "9.99",
      :sport => "Sport",
      :linetype => "Linetype"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Team1/)
    expect(rendered).to match(/Team2/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Sport/)
    expect(rendered).to match(/Linetype/)
  end
end
