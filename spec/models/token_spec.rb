require 'rails_helper'

RSpec.describe Token, :type => :model do
  it "generates a random hex token by default" do
    expect(Token.create.key).to match(/^[0-9a-f]{32}/)
  end
end
