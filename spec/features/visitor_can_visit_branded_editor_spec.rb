require 'spec_helper'

def app
  NoLightSinatra
end

RSpec.describe 'Visitor can visit branded editor', type: :feature do
  it 'loads the default editor' do
    visit_branded_editor(nil)

    expect(page.find_classes('body.editor')).not_to include(:dell)
    expect(page.find('#submission_html')['placeholder']).to eq('Enter your code here ...')
    expect(page.find('#submit').text).to eq('!light')
  end

  it 'loads the dell branded editor' do
    visit_branded_editor(:dell)

    expect(page.find_classes('body.editor')).to include(:dell)
    expect(page.find('#submission_html')['placeholder']).to eq('Enter your code here ...')
    expect(page.find('#submit').text).to eq('!light')
  end

  it 'loads the bloomberg editor' do
    visit_branded_editor(:bloomberg)

    expect(page.find_classes('body.editor')).to include(:bloomberg)
    expect(page.find('#submission_html')['placeholder']).to eq('Enter your code here ...')
    expect(page.find('#submit').text).to eq('!light')
  end

  private

  def visit_branded_editor(custom_branding)
    visit "/hacktheplanet/#{custom_branding}"
  end
end
