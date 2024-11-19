require 'dotenv/load' if ENV['RACK_ENV'] == 'development'
require_relative 'models/submission'

class NoLightSinatra < Sinatra::Base
  enable  :sessions

  use OmniAuth::Builder do
    provider :mlh, ENV['MY_MLH_KEY'], ENV['MY_MLH_SECRET'], scope: 'default'
  end

  set public_folder: 'public', static: true

  configure do
    DEFAULT_BRANDING = ''
    ENVIRONMENTS = {
      'development' => { 'uri' => 'mongodb://localhost/no_light_development' },
      'test'        => { 'uri' => 'mongodb://localhost/no_light_test' },
      'production'  => { 'uri' => ENV['MONGODB_URI'] }
    }

    MongoMapper.setup(ENVIRONMENTS, ENV['RACK_ENV'])
  end

  get '/' do
    erb :default_page
  end

  get '/auth/mlh/callback' do
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth["uid"]
    session[:full_name] = "#{auth[:info][:first_name]} #{auth[:info][:last_name]}"
    next_page = session[:redirect]

    if next_page
      session[:redirect] = nil
      redirect '%s' % next_page
    else
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/submit' do
    authorize do
      @submission = Submission.new(get_submit_params)

      if @submission.already_exists?
        erb :error, locals: {
          title: "Error - Already Submitted",
          message: "You have already submitted this code under your name (\"#{@submission.name}\")."
        }
      else
        @submission.save
        erb :submitted
      end
    end
  end

  get '/:hackathon.zip' do
    authorize do
      @submissions = Submission.by_hackathon(params[:hackathon])

      if @submissions.count > 0
        create_zip_folder(@submissions)
        set_response_headers
        download_zip_folder
      else
        erb :error, locals: {
          title: "Error - No Submissions",
          message: "We did not receive any submissions for your event (\"#{params[:hackathon]}\")."
        }
      end
    end
  end

  get '/:hackathon' do
    authorize do
      show_editor(DEFAULT_BRANDING)
    end
  end

  get '/:hackathon/:branding?' do
    authorize do
      show_editor(params[:branding])
    end
  end

  private

  def authorize
    if session[:user_id]
      yield
    else
      session[:redirect] = request.fullpath
      redirect '/auth/mlh'
    end
  end

  def show_editor(custom_branding)
    @body_class = ['editor', custom_branding].join(' ')
    erb :editor
  end

  def create_tempfile
    @create_tempfile ||= Tempfile.new(get_hackathon)
  end

  def get_submit_params
    get_submit_params = params[:submission] || {}
    get_submit_params.merge({
      'seconds' => seconds_from(params[:submission][:seconds]),
      'name' => session[:full_name]
    })
  end

  def get_hackathon
    params[:hackathon].to_s.downcase
  end

  def seconds_from(time_to_compare)
    (Time.now - Time.parse(time_to_compare)).to_i
  end

  def create_zip_folder(array = [])
    Zippy.create(create_tempfile.path) do |zip|
      if zip && block_given?
        yield(zip)
      else
        array.to_a.each do |entry|
          zip[entry.filename] = entry.html
        end
      end
    end
  end

  def download_zip_folder
    File.read(create_tempfile.path)
  end

  def set_response_headers
    response.headers['Pragma']                    = 'public'
    response.headers['Expires']                   = '0'
    response.headers['Cache-Control']             = 'must-revalidate, post-check=0, pre-check=0'
    response.headers['Cache-Control']             = 'public'
    response.headers['Content-Type']              = 'application/octet-stream'
    response.headers['Content-Disposition']       = 'attachment; filename="' + get_hackathon + '.zip"'
    response.headers['Content-Transfer-Encoding'] = 'binary'
    response.headers['Content-Length']            = create_tempfile.size
  end
end
