require "./spec_helper"

describe MySQL do
  described_class = -> {
    MySQL
  }

  subject = -> {
    described_class.call.new
  }

  connected = -> {
    subject.call.connect("127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil)
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

  describe "#escape_string" do
    it "provides protection from nasty queries" do
      subject.call.escape_string("'; DROP TABLE users; --").should eq("\\'; DROP TABLE users; --")
    end
  end

  describe "#connect" do
    it "fails with MySQL::ConnectionError when unable to connect" do
      begin
        subject.call.connect("127.0.0.1", "non-existent", "", "non-existent", 1234_u16, nil)
        raise Exception.new("should raise")
      rescue e
        e.should be_a(MySQL::ConnectionError)
        e.message.should match(/Can't connect to MySQL server/)
      end
    end

    it "does not fail when able to connect" do
      connected.call
    end
  end

  describe "#query" do
    it "works with simple queries" do
      connected.call.query("SELECT 1").should eq("1")
    end

    it "raises NotConnectedError when client is not connected" do
      begin
        subject.call.query("SELECT 1")
        raise Exception.new("should raise")
      rescue e
        e.should be_a(MySQL::NotConnectedError)
      end
    end
  end
end
