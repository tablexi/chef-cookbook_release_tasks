require "spec_helper"

RSpec.describe CookbookReleaseTasks do
  it "has a version number" do
    expect(CookbookReleaseTasks::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end