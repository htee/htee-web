require 'rails_helper'

RSpec.describe Stream, :type => :model do
  it "generates a random hex name by default" do
    expect(Stream.create.name).to match(/^[0-9a-f]{20}/)
  end
end
