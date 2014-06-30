require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  let(:user) { User.create(:login => SecureRandom.hex(5)) }

  describe "GET 'splash'" do
    it "returns http success" do
      get 'splash'
      expect(response).to be_success
    end
  end

  describe "POST 'stream'" do
    describe "without a name" do
      it "returns a 204 & Location header to the stream" do
        post :record, login: user.login

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to match(%r{^/#{user.login}/[0-9a-f]{20}$})
      end

      it "returns 403 when the login does not exist" do
        post :record, login: "fake"

        expect(response).to_not be_success
        expect(response.status).to eq(403)
      end
    end

    describe "with the name of a new stream" do
      it "returns a 204 & Location header to the stream" do
        post :record, login: user.login, name: 'test-stream'

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to eq("/#{user.login}/test-stream")
      end

      it "converts a url unsafe name" do
        post :record, login: user.login, name: 'hello world'

        expect(response).to be_success
        expect(response.status).to eq(204)

        location = response.headers['Location']
        expect(location).to eq("/#{user.login}/hello-world")
      end
    end
  end
end
