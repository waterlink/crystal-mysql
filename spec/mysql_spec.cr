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

  describe "#error" do
    it "returns empty string when everything is ok" do
      subject.call.error.should eq("")
    end

    it "returns an error when unable to connect" do
      mysql = subject.call
      begin
        mysql.connect("127.0.0.1", "non-existent", "", "non-existent", 1234_u16, nil)
      rescue
      end
      mysql.error.should match(/Can't connect to MySQL server/)
    end
  end
end
