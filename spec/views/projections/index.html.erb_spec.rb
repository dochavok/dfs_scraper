require 'rails_helper'

RSpec.describe "projections/index", type: :view do
  before(:each) do
    assign(:projections, [
      Projection.create!(
        :player => "Player",
        :fpts => "9.99",
        :team => "Team",
        :opponent => "Opponent",
        :position => "Position",
        :cost => 1,
        :source => "Source",
        :site => "Site",
        :sport => "Sport"
      ),
      Projection.create!(
        :player => "Player",
        :fpts => "9.99",
        :team => "Team",
        :opponent => "Opponent",
        :position => "Position",
        :cost => 1,
        :source => "Source",
        :site => "Site",
        :sport => "Sport"
      )
    ])
  end

  it "renders a list of projections" do
    render
    assert_select "tr>td", :text => "Player".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Team".to_s, :count => 2
    assert_select "tr>td", :text => "Opponent".to_s, :count => 2
    assert_select "tr>td", :text => "Position".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Source".to_s, :count => 2
    assert_select "tr>td", :text => "Site".to_s, :count => 2
    assert_select "tr>td", :text => "Sport".to_s, :count => 2
  end
end
