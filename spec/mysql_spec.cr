require "./spec_helper"

describe MySQL do
  described_class = -> {
    MySQL
  }

  subject = -> {
    described_class.call.new
  }

  describe "#initialize & .new" do
    it "creates instance of MySQL" do
      subject.call.should be_a(MySQL)
    end
  end

  describe "#client_info" do
    it "returns version" do
      subject.call.client_info.should match(%r{^\d+\.\d+\.\d+$})
    end
  end
end
