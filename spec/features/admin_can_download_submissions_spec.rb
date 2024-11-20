require 'spec_helper'

def app
  NoLightSinatra
end

RSpec.describe 'Admin can download submissions', type: :feature do
  before do
    mock_with_valid_mlh_credentials!

    10.times do
      create_submission(hackathon: 'hacktheplanet')
    end
  end

  it 'authenticates the user before they can download the zip' do
    get '/logout'
    get '/hacktheplanet.zip'

    expect(last_response.status).to eq(302)
    expect(last_response.location).to include("/auth/mlh")
  end

  it 'downloads the ZIP' do
    visit '/hacktheplanet.zip'

    expect(page.response_headers['Pragma']).to eq('public')
    expect(page.response_headers['Expires']).to eq('0')
    expect(page.response_headers['Cache-Control']).to eq('public')
    expect(page.response_headers['Content-Type']).to eq('application/octet-stream')
    expect(page.response_headers['Content-Disposition']).to eq('attachment; filename="hacktheplanet.zip"')
    expect(page.response_headers['Content-Transfer-Encoding']).to eq('binary')
  end

  it "creates a zip with the correct number of submissions" do
    zipfile = visit_and_get_zip_for('hacktheplanet')

    expect(Zippy.list(zipfile.path).count).to eq(10)
  end

  it "names the files within the zip as expected" do
    zipfile = visit_and_get_zip_for('hacktheplanet')
    actual_files = Zippy.list(zipfile.path)
    submissions = Submission.by_hackathon('hacktheplanet')

    submissions.each do |submission|
      expect(actual_files).to include(submission.filename)
    end
  end

  it "doesn't create zip files if empty" do
    visit '/empty_submissions_hackathon.zip'

    expect(page).to have_content('Error - No Submissions')
    expect(page).to have_content('We did not receive any submissions for your event ("empty_submissions_hackathon").')
  end

  private

  def create_submission(submission_params = {})
    submission_params = {
      hackathon: 'hacktheplanet',
      seconds: Time.now.to_s,
      html: "<h1>Hello dear world.</h1> <span>#{rand(1000)}</span>"
    }.merge(submission_params)

    visit "/#{submission_params[:hackathon]}"

    page.first('#submission_hackathon', visible: false).set(submission_params[:hackathon])
    page.first('#submission_seconds', visible: false).set(submission_params[:seconds])
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
