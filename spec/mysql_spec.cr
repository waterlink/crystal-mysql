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
    it "works with simple query" do
      connected.call.query("SELECT 1").should eq([[1]])
    end

    it "works with other simple query" do
      connected.call.query(%{SELECT 1, 2.5, NULL, 3, "hello world"}).should eq([[1, 2.5, nil, 3, "hello world"]])
    end

    it "works with commands" do
      connected.call.query(%{DROP TABLE IF EXISTS user}).should eq(nil)
      connected.call.query(%{CREATE TABLE user (id INT, email VARCHAR(255), name VARCHAR(255))})
        .should eq(nil)
    end

    it "allows to return multiple rows" do
      conn = connected.call
      conn.query(%{DROP TABLE IF EXISTS user})
      conn.query(%{CREATE TABLE user (id INT, email VARCHAR(255), name VARCHAR(255))})

      conn.query(%{INSERT INTO user(id, email, name) values(1, "john@example.com", "John Smith")})
      conn.query(%{INSERT INTO user(id, email, name) values(2, "sarah@example.com", "Sarah Smith")})

      conn.query(%{SELECT * FROM user})
        .should eq([
                    [1, "john@example.com", "John Smith"],
                    [2, "sarah@example.com", "Sarah Smith"],
                   ])
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
