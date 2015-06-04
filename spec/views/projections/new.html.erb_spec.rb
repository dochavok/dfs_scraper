require 'rails_helper'

RSpec.describe "projections/new", type: :view do
  before(:each) do
    assign(:projection, Projection.new(
      :player => "MyString",
      :fpts => "9.99",
      :team => "MyString",
      :opponent => "MyString",
      :position => "MyString",
      :cost => 1,
      :source => "MyString",
      :site => "MyString",
      :sport => "MyString"
    ))
  end

  it "renders new projection form" do
    render

    assert_select "form[action=?][method=?]", projections_path, "post" do

      assert_select "input#projection_player[name=?]", "projection[player]"

      assert_select "input#projection_fpts[name=?]", "projection[fpts]"

      assert_select "input#projection_team[name=?]", "projection[team]"

      assert_select "input#projection_opponent[name=?]", "projection[opponent]"

      assert_select "input#projection_position[name=?]", "projection[position]"

      assert_select "input#projection_cost[name=?]", "projection[cost]"

      assert_select "input#projection_source[name=?]", "projection[source]"

      assert_select "input#projection_site[name=?]", "projection[site]"

      assert_select "input#projection_sport[name=?]", "projection[sport]"
    end
  end
end
