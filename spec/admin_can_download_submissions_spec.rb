require_relative 'spec_helper'
require_relative 'acceptance_helper'

def app
  NoLightSinatra
end

describe NoLightSinatra do

  before do
    mock_with_valid_mlh_credentials!

    10.times do
      create_submission(hackathon: 'hacktheplanet')
    end
  end

  it 'authenticates the user before they can download the zip' do
    get '/logout'
    get '/hacktheplanet.zip'

    last_response.status.must_equal(302)
    last_response.location.must_include("/auth/mlh")
  end

  it 'downloads the ZIP' do
    visit '/hacktheplanet.zip'

    page.response_headers['Pragma'].must_equal                    'public'
    page.response_headers['Expires'].must_equal                   '0'
    page.response_headers['Cache-Control'].must_equal             'public'
    page.response_headers['Content-Type'].must_equal              'application/octet-stream'
    page.response_headers['Content-Disposition'].must_equal       'attachment; filename="hacktheplanet.zip"'
    page.response_headers['Content-Transfer-Encoding'].must_equal 'binary'
  end

  it "creates a zip with the correct number of submissions" do
    zipfile  = visit_and_get_zip_for 'hacktheplanet'

    Zippy.list(zipfile.path).count.must_equal 10
  end

  it "names the files within the zip as expected" do
    zipfile  = visit_and_get_zip_for 'hacktheplanet'
    actual_files = Zippy.list(zipfile.path)
    submissions = Submission.by_hackathon('hacktheplanet')

    submissions.each do |submission|
       actual_files.must_include submission.filename
    end
  end

  it "doesn't create zip files if empty" do
    visit '/empty_submissions_hackathon.zip'

    page.text.must_have_content 'Error - No Submissions'
    page.text.must_have_content 'We did not receive any submissions for your event ("empty_submissions_hackathon").'
  end

  private

  def create_submission(submission_params = {})
    submission_params = {
      hackathon: 'hacktheplanet',
      seconds:   Time.now.to_s,
      html:  "<h1>Hello dear world.</h1> <span>#{rand(1000)}</span>"
    }.merge(submission_params)

    visit '/%s' % submission_params[:hackathon]

    page.first('#submission_hackathon', visible: false).set(submission_params[:hackathon])
    page.first('#submission_seconds',   visible: false).set(submission_params[:seconds])
    page.first('#submission_html').set(submission_params[:html])

    page.click_button('!light')
  end

  def visit_and_get_zip_for(hackathon)
    visit "/#{hackathon}.zip"

    tempfile = Tempfile.new(hackathon)
    tempfile.write(page.source)
    tempfile.close

    tempfile    
  end
end