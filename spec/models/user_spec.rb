require 'rails_helper'

RSpec.describe User, :type => :model do
  it "generates a default token on user creation" do
    expect(User.create(login: 'testuser').tokens).to_not be_empty
  end
end
