require 'rails_helper'

RSpec.describe "prices/index", type: :view do
  before(:each) do
    assign(:prices, [
      Price.create!(
        :projection_id => 1,
        :sport => "Sport",
        :date => "MyText",
        :position => "Position",
        :team => "Team",
        :player => "Player",
        :salary => 2,
        :site => "Site",
        :site_id => 3,
        :salary_cap => 4,
        :format => "Format"
      ),
      Price.create!(
        :projection_id => 1,
        :sport => "Sport",
        :date => "MyText",
        :position => "Position",
        :team => "Team",
        :player => "Player",
        :salary => 2,
        :site => "Site",
        :site_id => 3,
        :salary_cap => 4,
        :format => "Format"
      )
    ])
  end

  it "renders a list of prices" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Sport".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Position".to_s, :count => 2
    assert_select "tr>td", :text => "Team".to_s, :count => 2
    assert_select "tr>td", :text => "Player".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Site".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Format".to_s, :count => 2
  end
end
