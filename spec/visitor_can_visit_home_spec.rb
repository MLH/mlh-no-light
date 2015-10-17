require_relative "spec_helper"
require_relative "acceptance_helper"

def app
  NoLightSinatra
end

describe NoLightSinatra do

  it 'loads the homepage' do
    visit '/'

    page.must_have_content 'To use, visit http://no-light.mlh.io/[enter hackathon name]'
  end

end