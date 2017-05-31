require_relative "spec_helper"
require_relative "acceptance_helper"

def app
  NoLightSinatra
end

describe NoLightSinatra do

  it 'loads the default editor' do
    visit_branded_editor(nil)

    page.find_classes('body.editor').wont_include       :dell
    page.find('#submission_html')["placeholder"].must_equal 'Enter your code here ...'
    page.find('#submit').text.must_equal                    '!light'
  end

  it 'loads the dell branded editor' do
    visit_branded_editor(:dell)

    page.find_classes('body.editor').must_include           :dell
    page.find('#submission_html')["placeholder"].must_equal 'Enter your code here ...'
    page.find('#submit').text.must_equal                    '!light'
  end

  it 'loads the bloomberg editor' do
    visit_branded_editor(:bloomberg)

    page.find_classes('body.editor').must_include           :bloomberg
    page.find('#submission_html')["placeholder"].must_equal 'Enter your code here ...'
    page.find('#submit').text.must_equal                    '!light'
  end

  private

  def visit_branded_editor(custom_branding)
    visit "/hacktheplanet/%s" % (custom_branding)
  end

end