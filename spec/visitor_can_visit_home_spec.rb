require_relative "spec_helper"
require_relative "acceptance_helper"

describe NoLightSinatra do

  it 'can find NoLightSinatra class' do
    NoLightSinatra.must_be_kind_of Class
  end

  it 'loads the homepage' do
    visit '/'
    page.must_have_content 'To use, visit http://no-light.mlh.io/[enter hackathon name]'
  end

end