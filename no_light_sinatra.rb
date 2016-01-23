require_relative 'models/submission'

class NoLightSinatra < Sinatra::Base
  set public_folder: 'public', static: true

  configure do
    DEFAULT_BRANDING = 'dell'
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

  post '/submit' do
    @submission = Submission.new(get_submit_params)

    if @submission.already_exists?
      erb :error
    else
      @submission.save
      erb :submitted
    end
  end

  get '/:hackathon.zip' do
    if @submissions = Submission.by_hackathon(params[:hackathon])
      create_zip_folder(@submissions)
      set_response_headers
      download_zip_folder
    end
  end

  get '/:hackathon' do
    show_editor(DEFAULT_BRANDING)
  end

  get '/:hackathon/:branding' do
    show_editor(params[:branding])
  end

  private

  def show_editor(custom_branding)
    @body_class = ['editor', custom_branding].join(' ')
    erb :editor
  end

  def create_tempfile
    @create_tempfile ||= Tempfile.new(get_hackathon)
  end

  def get_submit_params
    get_submit_params = params[:submission] || {}
    get_submit_params.merge('seconds' => seconds_from(params[:submission][:seconds]))
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