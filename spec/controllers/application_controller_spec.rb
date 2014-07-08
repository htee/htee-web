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

    describe "without a name" do
      it "returns a 204 & Location header to the stream" do
        post :record, owner: user.login

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to match(%r{^/#{user.login}/[0-9a-f]{20}$})
      end

      it "returns 403 when the owner does not exist" do
        post :record, owner: "fake"

        expect(response).to_not be_success
        expect(response.status).to eq(401)
      end
    end

    describe "with the name of a new stream" do
      it "returns a 204 & Location header to the stream" do
        post :record, owner: user.login, name: 'test-stream'

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to eq("/#{user.login}/test-stream")
      end

      it "converts a url unsafe name" do
        post :record, owner: user.login, name: 'hello world'

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to eq("/#{user.login}/hello-world")
      end
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

    it "returns a 204 for a stream" do
      stream = user.streams.create

      get :playback, owner: user.login, name: stream.name

      expect(response).to be_success
      expect(response.status).to eq(204)
    end
  end
end
