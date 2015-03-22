require "./spec_helper"

describe MySQL do
  describe ".connect" do
    it "creates new connection and delegates to its #connect" do
      conn = MySQL.connect("127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil)
      conn.query(%{SELECT 1}).should eq([[1]])
    end
  end
end
