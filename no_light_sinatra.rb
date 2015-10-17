require_relative 'models/submission'

class NoLightSinatra < Sinatra::Base
  set public_folder: 'public', static: true

  configure do
    environments = {
      'development' => { 'uri' => 'mongodb://localhost/no_light_development' },
      'test'        => { 'uri' => 'mongodb://localhost/no_light_test' },
      'production'  => { 'uri' => ENV['MONGODB_URI'] }
    }

    MongoMapper.setup(environments, ENV['RACK_ENV'])
  end

  get '/' do show_default_page end

  post '/submit' do
    @submission = Submission.new(get_submit_params)

    if @submission.already_exists?
      show_error
    else
      @submission.save
      show_submitted
    end
  end

  get '/:hackathon.zip' do
    if @submissions = Submission.by_hackathon(get_hackathon)
      create_zip_folder(@submissions)
      set_response_headers
      download_zip_folder
    end
  end

  get '/:hackathon' do show_editor end
  get '/:hackathon/:branding' do show_editor(params[:branding]) end

  private

  def show_default_page
    erb :default_page
  end

  def show_error
    erb :error
  end

  def show_submitted
    erb :submitted
  end

  def show_editor(custom_branding = 'dell')
    @body_class = ['editor', custom_branding].join(' ')
    erb :editor
  end

  def create_tempfile
    @create_tempfile = Tempfile.new(get_hackathon)
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
      if block_given?
        yield(zip)
      else
        array.to_a.each { |entry| zip[entry.filename] = entry.html }
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
