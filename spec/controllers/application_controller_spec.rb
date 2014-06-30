require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  describe "GET 'splash'" do
    it "returns http success" do
      get 'splash'
      expect(response).to be_success
    end
  end

end
