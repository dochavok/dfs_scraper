require 'rails_helper'

RSpec.describe "lines/index", type: :view do
  before(:each) do
    assign(:lines, [
      Line.create!(
        :team1 => "Team1",
        :team2 => "Team2",
        :over_under => "9.97",
        :team1_line => "9.98",
        :team2_line => "9.99",
        :sport => "Sport",
        :linetype => "Linetype"
      ),
      Line.create!(
        :team1 => "Team1",
        :team2 => "Team2",
        :over_under => "9.97",
        :team1_line => "9.98",
        :team2_line => "9.99",
        :sport => "Sport",
        :linetype => "Linetype"
      )
    ])
  end

  it "renders a list of lines" do
    render
    assert_select "tr>td", :text => "Team1".to_s, :count => 2
    assert_select "tr>td", :text => "Team2".to_s, :count => 2
    assert_select "tr>td", :text => "9.97".to_s, :count => 2
    assert_select "tr>td", :text => "9.98".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Sport".to_s, :count => 2
    assert_select "tr>td", :text => "Linetype".to_s, :count => 2
  end
end
