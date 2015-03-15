require "./spec_helper"

describe MySQL do
  describe "#initialize & .new" do
    it "creates instance of MySQL" do
      (MySQL.new).should be_a(MySQL)
    end
  end
end
