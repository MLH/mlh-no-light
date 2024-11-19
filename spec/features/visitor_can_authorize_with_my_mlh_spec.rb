require "spec_helper"

def app
  NoLightSinatra
end

RSpec.describe 'Visitor can authorize with MyMLH', type: :feature do
  before do
    mock_with_valid_mlh_credentials!
  end

  it 'redirects the un-branded editor visitors to MyMLH' do
    get '/hacktheplanet'

    expect(last_response.status).to eq(302)
    expect(last_response.location).to include("/auth/mlh")
  end

  it 'redirects the branded editor visitors to MyMLH' do
    get '/hacktheplanet/dell'

    expect(last_response.status).to eq(302)
    expect(last_response.location).to include("/auth/mlh")
  end

  it 'displays the editor to signed in users' do
    sign_in!

    get '/hacktheplanet'

    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/hacktheplanet")
  end

  it 'displays the user\'s name' do
    sign_in!

    visit '/hacktheplanet'

    expect(page.find('.current-user span').text).to eq("You are playing !Light as Grace Hopper.")
  end

  it 'allows a user to logout' do
    sign_in!
    visit '/hacktheplanet'

    click_link "Logout"

    expect(page).not_to have_css('.current-user')
  end

  it 'redirects authorized users to the previous page' do
    visit '/hacktheplanet-test'

    expect(current_path).to eq('/hacktheplanet-test')
  end

  private

  def sign_in!
    get '/auth/mlh'
    follow_redirect!
  end
end
