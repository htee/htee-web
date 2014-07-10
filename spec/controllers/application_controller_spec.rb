require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  let(:user) { User.create(:login => SecureRandom.hex(5)) }
  let(:token_auth) { ActionController::HttpAuthentication::Token.encode_credentials(user.tokens.first.key) }

  describe "GET 'splash'" do
    it "returns http success" do
      get 'splash'
      expect(response).to be_success
    end
  end

  describe "POST 'record'" do
    before do
      request.env['HTTP_AUTHORIZATION'] = token_auth
    end

    it "returns a 202 rewrite with a path to the stream" do
      post :record

      expect(response).to be_success
      expect(response.status).to eq(202)

      rewrite = JSON.parse(response.body)
      location = rewrite['path']

      expect(location).to match(%r{^/#{user.login}/[0-9a-f]{20}$})
    end
  end

  describe "GET 'playback'" do
    it "returns 404 if the user does not exist" do
      stream = user.streams.create

      get :playback, owner: 'fake', name: stream.name

      expect(response).to_not be_success
      expect(response.status).to eq(404)
    end

    it "returns 404 if the stream does not exist" do
      get :playback, owner: user.login, name: 'fake-stream'

      expect(response).to_not be_success
      expect(response.status).to eq(404)
    end

    it "returns a 202 for a stream" do
      stream = user.streams.create

      get :playback, owner: user.login, name: stream.name

      expect(response).to be_success
      expect(response.status).to eq(202)
    end
  end
end
