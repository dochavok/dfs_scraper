require 'rails_helper'

RSpec.describe "prices/new", type: :view do
  before(:each) do
    assign(:price, Price.new(
      :projection_id => 1,
      :sport => "MyString",
      :date => "MyText",
      :position => "MyString",
      :team => "MyString",
      :player => "MyString",
      :salary => 1,
      :site => "MyString",
      :site_id => 1,
      :salary_cap => 1,
      :format => "MyString"
    ))
  end

  it "renders new price form" do
    render

    assert_select "form[action=?][method=?]", prices_path, "post" do

      assert_select "input#price_projection_id[name=?]", "price[projection_id]"

      assert_select "input#price_sport[name=?]", "price[sport]"

      assert_select "textarea#price_date[name=?]", "price[date]"

      assert_select "input#price_position[name=?]", "price[position]"

      assert_select "input#price_team[name=?]", "price[team]"

      assert_select "input#price_player[name=?]", "price[player]"

      assert_select "input#price_salary[name=?]", "price[salary]"

      assert_select "input#price_site[name=?]", "price[site]"

      assert_select "input#price_site_id[name=?]", "price[site_id]"

      assert_select "input#price_salary_cap[name=?]", "price[salary_cap]"

      assert_select "input#price_format[name=?]", "price[format]"
    end
  end
end
