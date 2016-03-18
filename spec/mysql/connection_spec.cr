require "../spec_helper"

class TestError < Exception; end

module MySQL
  describe Connection do
    described_class = -> {
      Connection
    }

    subject = -> {
      described_class.call.new
    }

    connected = -> {
      subject.call.connect("127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil)
    }

    version = -> {
      subject.call.client_info
    }

    describe "#initialize & .new" do
      it "creates instance of Connection" do
        subject.call.should be_a(Connection)
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

    describe "#connect" do
      it "fails with ConnectionError when unable to connect" do
        expect_raises(Errors::Connection, /Can't connect to MySQL server/) do
          subject.call.connect("127.0.0.1", "non-existent", "", "non-existent", 1234_u16, nil)
        end
      end

      it "does not fail when able to connect" do
        connected.call
      end
    end

    describe "#options" do
      it "returns success when setting an option" do
        mysql = subject.call
        result = mysql.set_option(LibMySQL::MySQLOption::MYSQL_SET_CHARSET_NAME, "utf8")
        result.should eq 0
      end
    end

    describe "#insert_id" do
      it "works with simple insert query" do
        conn = connected.call

        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT PRIMARY KEY NOT NULL AUTO_INCREMENT, created_on DATE, what VARCHAR(50))})

        conn.query(%{INSERT INTO event(created_on, what) values('2005-03-27', 'order')})
        conn.insert_id.should eq(1)

        conn.query(%{INSERT INTO event(created_on, what) values('2005-04-05', 'shipment')})
        conn.insert_id.should eq(2)

        conn.query(%{INSERT INTO event(created_on, what) values('2005-06-14', 'return')})
        conn.insert_id.should eq(3)

        conn.query(%{SELECT * FROM event})
          .should eq([
                      [1, Time::Format.new("%F").parse("2005-03-27"), "order"],
                      [2, Time::Format.new("%F").parse("2005-04-05"), "shipment"],
                      [3, Time::Format.new("%F").parse("2005-06-14"), "return"],
                     ])
      end

      it "does not work if query was not insert" do
        conn = connected.call

        conn.query("SELECT 1")
        expect_raises(Errors::UnableToFetchLastInsertId) do
          conn.insert_id.should eq(0)
        end
      end
    end

    describe "#query" do
      it "works with simple query" do
        connected.call.query("SELECT 1").should eq([[1]])
      end

      it "works with other simple query" do
        connected.call.query(%{SELECT 1, 2.5, NULL, 3, "hello world"}).should eq([[1, 2.5, nil, 3, "hello world"]])
      end

      it "works with timestamp" do
        conn = connected.call
        conn.query(%{SET time_zone='+0:00'})
        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT, created_at TIMESTAMP, what VARCHAR(50))})

        conn.query(%{INSERT INTO event values(1, '2005-03-27 02:00:00', 'login')})
        conn.query(%{INSERT INTO event values(2, '2005-03-27 02:02:00', 'logout')})

        conn.query(%{SELECT * FROM event})
          .should eq([
                      [1, Time::Format.new("%F %T").parse("2005-03-27 02:00:00"), "login"],
                      [2, Time::Format.new("%F %T").parse("2005-03-27 02:02:00"), "logout"],
                     ])
      end

      it "works with datetime" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT, created_at DATETIME, what VARCHAR(50))})

        conn.query(%{INSERT INTO event values(1, '2005-03-27 02:00:00', 'login')})
        conn.query(%{INSERT INTO event values(2, '2005-03-27 02:02:00', 'logout')})

        conn.query(%{SELECT * FROM event})
          .should eq([
                      [1, Time::Format.new("%F %T").parse("2005-03-27 02:00:00"), "login"],
                      [2, Time::Format.new("%F %T").parse("2005-03-27 02:02:00"), "logout"],
                     ])
      end

      it "works with date" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT, created_on DATE, what VARCHAR(50))})

        conn.query(%{INSERT INTO event values(1, '2005-03-27', 'order')})
        conn.query(%{INSERT INTO event values(2, '2005-04-05', 'shipment')})

        conn.query(%{SELECT * FROM event})
          .should eq([
                      [1, Time::Format.new("%F").parse("2005-03-27"), "order"],
                      [2, Time::Format.new("%F").parse("2005-04-05"), "shipment"],
                     ])
      end

      it "works with year(4)" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT, created_on YEAR, what VARCHAR(50))})

        conn.query(%{INSERT INTO event values(1, '2044', 'order')})
        conn.query(%{INSERT INTO event values(2, '89', 'shipment')})

        conn.query(%{SELECT * FROM event})
          .should eq([
                      [1, 2044, "order"],
                      [2, 1989, "shipment"],
                     ])
      end

      it "works with year(2)" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS event})
        conn.query(%{CREATE TABLE event (id INT, created_on YEAR(2), what VARCHAR(50))})

        conn.query(%{INSERT INTO event values(1, '2044', 'order')})
        conn.query(%{INSERT INTO event values(2, '89', 'shipment')})

        if version.call =~ /5\.6/
          conn.query(%{SELECT * FROM event})
            .should eq([
                         [1, 2044, "order"],
                         [2, 1989, "shipment"],
                       ])
        else
          conn.query(%{SELECT * FROM event})
            .should eq([
                         [1, 44, "order"],
                         [2, 89, "shipment"],
                       ])
        end
      end

      it "works with small bit type" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS flags})
        conn.query(%{CREATE TABLE flags (id INT, value BIT(6), description VARCHAR(100))})

        conn.query(%{INSERT INTO flags values(1, b'000101', 'hello')})
        conn.query(%{INSERT INTO flags values(2, b'1001', 'some interesting stuff')})

        conn.query(%{SELECT * FROM flags})
          .should eq([
                      [1, 5, "hello"],
                      [2, 9, "some interesting stuff"],
                     ])
      end

      it "works with big bit type" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS flags})
        conn.query(%{CREATE TABLE flags (id INT, value BIT(64), description VARCHAR(100))})

        conn.query(%{INSERT INTO flags values(1, b'000101', 'hello')})
        conn.query(%{INSERT INTO flags values(2, b'0100000000100000000000000000000000000000000000000000001000000001', 'some interesting stuff')})

        conn.query(%{SELECT * FROM flags})
          .should eq([
                      [1, 5, "hello"],
                      [2, 4620693217682129409, "some interesting stuff"],
                     ])
      end

      it "works with boolean type" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS user})
        conn.query(%{CREATE TABLE user (id INT, email VARCHAR(255), activated BOOLEAN)})

        conn.query(%{INSERT INTO user VALUES(1, "john@example.org", TRUE)})
        conn.query(%{INSERT INTO user VALUES(2, "sarah@example.org", FALSE)})

        conn.query(%{SELECT * FROM user})
          .should eq([
                      [1, "john@example.org", true],
                      [2, "sarah@example.org", false],
                     ])
      end

      it "works with blob type" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS data})
        conn.query(%{CREATE TABLE data (id INT, data blob)})

        MySQL::Query.new(%{INSERT INTO data VALUES(1, :data)}, {"data" => Slice(UInt8).new(10, 1_u8)}).run(conn)

        conn.query(%{SELECT * FROM data})
            .should eq([
          [1, Slice(UInt8).new(10, 1_u8)],
        ])
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
        expect_raises(Errors::NotConnected) do
          subject.call.query("SELECT 1")
        end
      end

      it "works correctly with NULL values" do
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS people})
        conn.query(%{CREATE TABLE people (id INT, name VARCHAR(50), note VARCHAR(50), score INT)})

        conn.query(%{INSERT INTO people VALUES(546, NULL, NULL, 3)})
        conn.query(%{INSERT INTO people VALUES(547, 'maria', '', 3)})
        conn.query(%{INSERT INTO people VALUES(548, 'maria', NULL, 3)})

        conn.query(%{SELECT * FROM people})
          .should eq([
            [546, nil, nil, 3],
            [547, "maria", "", 3],
            [548, "maria", nil, 3],
          ])
      end

      it "works with UTF8 characters" do
        conn = connected.call
        conn.set_option(LibMySQL::MySQLOption::MYSQL_SET_CHARSET_NAME, "utf8")

        conn.query(%{DROP TABLE IF EXISTS people})
        conn.query(%{CREATE TABLE people (id INT, name VARCHAR(50), note VARCHAR(50), score INT)})

        conn.query(%{INSERT INTO people VALUES(549, "フレーム", "ワークのベンチマーク", 1)})

        conn.query(%{SELECT * FROM people})
          .should eq([
            [549,"フレーム", "ワークのベンチマーク", 1],
          ])
      end
    end

    describe "#close" do
      it "closes the connection" do
        conn = connected.call
        conn.close

        expect_raises(Errors::NotConnected) do
          conn.query(%{SELECT 1})
        end
      end
    end

    describe "#transaction" do
      create_users = -> {
        conn = connected.call
        conn.query(%{DROP TABLE IF EXISTS user})
        conn.query(%{CREATE TABLE user (id INT, email VARCHAR(255), name VARCHAR(255))})
        conn.close
      }

      context "when not using transactions" do
        it "different connections can see changes of each other" do
          create_users.call
          conn0 = connected.call
          conn1 = connected.call

          conn0.query(%{INSERT INTO user values(1, 'john@example.org', 'John')})
          conn1.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
          conn1.query(%{INSERT INTO user values(2, 'sarah@example.org', 'Sarah')})
          conn0.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
        end
      end

      context "when using transactions" do
        it "different connections can not see changes of each other" do
          create_users.call
          conn0 = connected.call
          conn1 = connected.call

          conn0.transaction do
            conn0.query(%{INSERT INTO user values(1, 'john@example.org', 'John')})

            conn1.transaction do
              conn0.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
              conn1.query(%{SELECT COUNT(id) FROM user}).should eq([[0]])

              conn1.query(%{INSERT INTO user values(2, 'sarah@example.org', 'Sarah')})

              conn0.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
              conn1.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
            end

            conn0.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
            conn1.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
          end

          conn0.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
          conn1.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
        end

        it "rolls back transaction when it fails" do
          create_users.call
          conn = connected.call

          expect_raises(TestError) do
            conn.transaction do
              conn.query(%{INSERT INTO user values(1, 'john@example.org', 'John')})
              conn.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
              raise TestError.new
            end
          end

          conn.query(%{SELECT COUNT(id) FROM user}).should eq([[0]])
        end

        it "works as expected when nested transactions are used" do
          create_users.call
          conn = connected.call

          conn.transaction do
            conn.query(%{SELECT COUNT(id) FROM user}).should eq([[0]])
            conn.query(%{INSERT INTO user values(1, 'john@example.org', 'John')})
            conn.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])

            conn.transaction do
              conn.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
              conn.query(%{INSERT INTO user values(2, 'sarah@example.org', 'Sarah')})
              conn.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
            end

            expect_raises(TestError) do
              conn.transaction do
                conn.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
                conn.query(%{INSERT INTO user values(2, 'sarah@example.org', 'Sarah')})
                conn.query(%{SELECT COUNT(id) FROM user}).should eq([[3]])
                raise TestError.new
              end
            end

            conn.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
          end

          conn.query(%{SELECT COUNT(id) FROM user}).should eq([[2]])
        end

        it "raises UnableToRollbackTransaction when it is unable to roll it back" do
          create_users.call
          conn = connected.call

          expect_raises(Errors::UnableToRollbackTransaction, /Errors::NotConnected/) do
            conn.transaction do
              conn.query(%{INSERT INTO user values(1, 'john@example.org', 'John')})
              conn.query(%{SELECT COUNT(id) FROM user}).should eq([[1]])
              conn.close
              raise TestError.new
            end
          end

          connected.call.query(%{SELECT COUNT(id) FROM user}).should eq([[0]])
        end
      end
    end
  end
end
