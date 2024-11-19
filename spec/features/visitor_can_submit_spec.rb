require 'spec_helper'

RSpec.describe 'Visitor can submit', type: :feature do
  let(:app) { NoLightSinatra }

  before do
    mock_with_valid_mlh_credentials!
  end

  it 'submits an entry' do
    visit '/random-hackathon'
    fill_in_submission(name: 'Mike Swift')

    expect(page).to have_content 'Submission received'
    expect(page).to have_content 'It took you %s minutes' % [last_submission.to_min_secs]
    expect(page).to have_content 'You wrote %s lines of code / %s bytes.' % [last_submission.lines, last_submission.bytes]
  end

  it 'authenticates the user before they can submit' do
    post '/submit'

    expect(last_response.status).to eq(302)
    expect(last_response.location).to include("/auth/mlh")
  end

  it 'submits a duplicate entry' do
    submit_an_entry = lambda {
      visit '/random-hackathon'
      fill_in_submission
    }

    submit_an_entry.call

    expect(page).to have_content 'Submission received'
    expect(page).to have_content 'It took you %s minutes' % [last_submission.to_min_secs]
    expect(page).to have_content 'You wrote %s lines of code / %s bytes.' % [last_submission.lines, last_submission.bytes]

    # Attempt to re-submit the exact same entry.
    submit_an_entry.call

    expect(page).to have_content 'Error - Already Submitted'
    expect(page).to have_content 'You have already submitted this code under your name ("Grace Hopper").'
  end

  it 'submits a different entry' do
    visit '/random-hackathon'
    fill_in_submission(name: 'Mike Swift', hackathon: 'treehacks')

    expect(page).to have_content 'Submission received'
    expect(page).to have_content 'It took you %s minutes' % [last_submission.to_min_secs]
    expect(page).to have_content 'You wrote %s lines of code / %s bytes.' % [last_submission.lines, last_submission.bytes]
  end

  private

  def fill_in_submission(submission_params = {})
    submission_params = {
      hackathon: 'random-hackathon',
      seconds: Time.now.to_s,
      html: File.read(File.join('spec', 'testdata', 'entry.html'))
    }.merge(submission_params)

    page.first('#submission_hackathon', visible: false).set(submission_params[:hackathon])
    page.first('#submission_seconds', visible: false).set(submission_params[:seconds])
    page.first('#submission_html', visible: true).set(submission_params[:html])

    page.click_button('!light')
  end

  def last_submission
    Submission.last
  end
end
