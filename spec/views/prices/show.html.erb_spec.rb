require 'rails_helper'

RSpec.describe "prices/show", type: :view do
  before(:each) do
    @price = assign(:price, Price.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Sport/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Position/)
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/Player/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Site/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Format/)
  end
end
