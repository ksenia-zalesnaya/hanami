require 'test_helper'
require 'rack/test'

describe Hanami::Container do
  include Rack::Test::Methods

  before do
    Hanami::Container.configure do
      mount Front::Application, at: '/front'
      mount Back::Application,  at: '/back'
    end

    Front::Application.load!
    Back::Application.load!

    @container = Hanami::Container.new
  end

  def app
    @container
  end

  def response
    last_response
  end

  it 'reach to endpoints' do
    get '/back/home'
    response.status.must_equal 200
    response.body.must_equal 'hello Back'

    get '/front/home'
    response.status.must_equal 200
    response.body.must_equal 'hello Front'

    get '/back/users'
    response.status.must_equal 200
    response.body.must_equal 'hello from Back users endpoint'

    get '/front/faq'
    response.status.must_equal 200
    response.body.must_equal 'hello from Faq'
  end

  it 'print correct routes' do
    matches = [
      'GET, HEAD  /front/home                    Front::Controllers::Home::Show',
      'GET, HEAD  /front/faq                     Front::Controllers::FAQ::Index',
      'GET, HEAD  /back/home                     Back::Controllers::Home::Show',
      'GET, HEAD  /back/users                    Back::Controllers::Users::Index'
    ]
    matches.each do |match|
      app.routes.inspector.to_s.must_match match
    end
  end

  it 'generate correct urls with route helpers' do
    Front::Routes.path(:home).must_equal '/front/home'
    Back::Routes.path(:home).must_equal '/back/home'
  end

  it 'print correct request url' do
    get '/back/articles'
    response.status.must_equal 200
    response.body.must_equal 'http://example.org/back/articles'
  end
end
