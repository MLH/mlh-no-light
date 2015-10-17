require_relative 'spec_helper'
require_relative 'acceptance_helper'

def app
  NoLightSinatra
end

describe NoLightSinatra do

  it 'downloads the ZIP' do
    10.times do
      create_submission(hackathon: 'hacktheplanet')
    end

    visit_download_and_validate_zip 'hacktheplanet'
  end

  private

  def create_submission(submission_params = {})
    submission_params = {
      hackathon: 'hacktheplanet',
      seconds:   Time.now.to_s,
      name:      Faker::Name.name,
      textarea:  '<h1>Hello dear world.</h1>'
    }.merge(submission_params)

    visit '/%s' % submission_params[:hackathon]

    page.first('#submission_hackathon', visible: false).set(submission_params[:hackathon])
    page.first('#submission_seconds',   visible: false).set(submission_params[:seconds])
    page.first('#submission_name',      visible: false).set(submission_params[:name])
    page.first('#submission_html').set(submission_params[:html])

    page.click_button('!light')
  end

  def visit_download_and_validate_zip(hackathon)
    visit '/%s.zip' % hackathon

    page.response_headers['Pragma'].must_equal                    'public'
    page.response_headers['Expires'].must_equal                   '0'
    page.response_headers['Cache-Control'].must_equal             'public'
    page.response_headers['Content-Type'].must_equal              'application/octet-stream'
    page.response_headers['Content-Disposition'].must_equal       'attachment; filename="' + hackathon + '.zip"'
    page.response_headers['Content-Transfer-Encoding'].must_equal 'binary'

    # Need to add tests to check the contents of the ZIP.
    # Currently `page.body` isn't returning anything. Need to investigate.
  end
end