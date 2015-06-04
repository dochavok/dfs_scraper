require 'rails_helper'

RSpec.describe "lines/edit", type: :view do
  before(:each) do
    @line = assign(:line, Line.create!(
      :team1 => "MyString",
      :team2 => "MyString",
      :over_under => "9.99",
      :team1_line => "9.99",
      :team2_line => "9.99",
      :sport => "MyString",
      :linetype => "MyString"
    ))
  end

  it "renders the edit line form" do
    render

    assert_select "form[action=?][method=?]", line_path(@line), "post" do

      assert_select "input#line_team1[name=?]", "line[team1]"

      assert_select "input#line_team2[name=?]", "line[team2]"

      assert_select "input#line_over_under[name=?]", "line[over_under]"

      assert_select "input#line_team1_line[name=?]", "line[team1_line]"

      assert_select "input#line_team2_line[name=?]", "line[team2_line]"

      assert_select "input#line_sport[name=?]", "line[sport]"

      assert_select "input#line_linetype[name=?]", "line[linetype]"
    end
  end
end
