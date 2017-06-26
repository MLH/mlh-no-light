require_relative 'spec_helper'
require_relative 'acceptance_helper'

def app
  NoLightSinatra
end

describe NoLightSinatra do

  before do
    mock_with_valid_mlh_credentials!
  end

  it 'submit an entry' do
    visit '/random-hackathon'
    fill_in_submission(name: 'Mike Swift')

    page.text.must_have_content 'Submission received'
    page.text.must_have_content 'IT TOOK YOU %s MINUTES'                 % [last_submission.to_min_secs]
    page.text.must_have_content 'YOU WROTE %s LINES OF CODE / %s BYTES.' % [last_submission.lines, last_submission.bytes]
  end

  it 'authenticates the user before they can submit' do
    post  '/submit'

    last_response.status.must_equal(302)
    last_response.location.must_include("/auth/mlh")
  end

  it 'submit a duplicate entry' do
    submit_an_entry = lambda { 
      visit '/random-hackathon'
      fill_in_submission
    }

    submit_an_entry.call

    page.text.must_have_content 'Submission received'
    page.text.must_have_content 'IT TOOK YOU %s MINUTES'                 % [last_submission.to_min_secs]
    page.text.must_have_content 'YOU WROTE %s LINES OF CODE / %s BYTES.' % [last_submission.lines, last_submission.bytes]

    # Attempt to re-submit the exact same entry.
    submit_an_entry.call

    page.text.must_have_content 'Error - Already Submitted'
    page.text.must_have_content 'You have already submitted this code under your name ("Grace Hopper").'
  end

  it 'submit a different entry' do
    visit '/random-hackathon'
    fill_in_submission(name: 'Mike Swift', hackathon: 'treehacks')

    page.text.must_have_content 'Submission received'
    page.text.must_have_content 'IT TOOK YOU %s MINUTES'                 % [last_submission.to_min_secs]
    page.text.must_have_content 'YOU WROTE %s LINES OF CODE / %s BYTES.' % [last_submission.lines, last_submission.bytes]
  end 

  private

  def fill_in_submission(submission_params = {})
    submission_params = {
      hackathon: 'random-hackathon',
      seconds:   Time.now.to_s,
      html:      File.read(File.join('spec', 'testdata', 'entry.html'))
    }.merge(submission_params)

    page.first('#submission_hackathon', visible: false).set(submission_params[:hackathon])
    page.first('#submission_seconds',   visible: false).set(submission_params[:seconds])
    page.first('#submission_html',      visible: true).set(submission_params[:html])

    page.click_button('!light')
  end

  def last_submission
    Submission.last
  end
end