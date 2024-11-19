require 'spec_helper'

RSpec.describe 'Visitor can visit home', type: :feature do
  it 'can find NoLightSinatra class' do
    expect(NoLightSinatra).to be_a(Class)
  end

  it 'loads the homepage' do
    visit '/'
    expect(page).to have_content('To use, visit http://no-light.mlh.io/[enter hackathon name]')
  end
end
