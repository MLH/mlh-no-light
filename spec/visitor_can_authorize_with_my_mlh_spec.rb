require_relative "spec_helper"
require_relative "acceptance_helper"
require 'pry'

def app
  NoLightSinatra
end

describe NoLightSinatra do

  before do
    mock_with_valid_mlh_credentials!
  end

  it 'the un-branded editor redirects visitors to MyMLH' do
    get '/hacktheplanet'

    last_response.status.must_equal(302)
    last_response.location.must_include("/auth/mlh")
  end

  it 'the branded editor redirects visitors to MyMLH' do
    get '/hacktheplanet/dell'

    last_response.status.must_equal(302)
    last_response.location.must_include("/auth/mlh")
  end

  it 'displays the editor to signed in users' do
    sign_in!

    get '/hacktheplanet'

    last_response.status.must_equal(200)
    last_request.path.must_equal("/hacktheplanet")
  end

  it 'displays the users name' do
    sign_in!

    visit '/hacktheplanet'

    page.find('.current-user span').text.must_equal "You are playing !Light as Grace Hopper."
  end

  it 'allows a user to logout' do
    sign_in!
    visit '/hacktheplanet'

    click_link "Logout"

    page.has_css?('.current-user').must_equal false
  end

  it 'redirects authorized users to the previous page' do
    visit '/hacktheplanet-test'

    current_path.must_equal('/hacktheplanet-test')
  end

  private

  def sign_in!
    get '/auth/mlh'
    follow_redirect!
  end
end
