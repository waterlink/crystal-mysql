require "../spec_helper"

class TestError < Exception; end

module MySQL
  describe ConnectionPool do
    described_class = ->{
      ConnectionPool
    }

    subject = ->{
      described_class.call.new "MyPool", 2, "127.0.0.1", "crystal_mysql", "", "crystal_mysql_test", 3306_u16, nil
    }

    describe "#initialize & .new" do
      it "creates instance of ConnectionPool" do
        subject.call.should be_a(ConnectionPool)
      end
    end

    describe "#error" do
      it "fails with ConnectionPoolExchaustednError when pool has no connections left" do
        pool = subject.call
        a = pool.get_connection
        b = pool.get_connection
        expect_raises(Errors::ConnectionPoolExhaustedError) do
          pool.get_connection
        end

        a.close
        b.close
      end

      it "fails with connection that was returned to pool already" do
        pool = subject.call
        a = pool.get_connection
        a.close

        expect_raises(Errors::NotConnected) do
          a.query("SELECT 1")
        end
      end
    end

    describe "#connections" do
      it "shows pool has no connections left" do
        pool = subject.call
        a = pool.get_connection
        b = pool.get_connection
        pool.get_connection?.should eq false
      end

      it "shows pool has regains connections on close" do
        pool = subject.call
        a = pool.get_connection
        b = pool.get_connection
        a.close

        pool.get_connection?.should eq true
        pool.get_connections_left.should eq 1

        b.close

        c = pool.get_connection
        d = pool.get_connection

        pool.get_connection?.should eq false

        c.query("SELECT 1")
        d.query("SELECT 1")

        c.close
        d.close

        pool.get_connection?.should eq true
      end
    end

    describe "#insert_id" do
      it "works with simple insert query using pooled connections" do
        pool = subject.call
        a = pool.get_connection
        b = pool.get_connection
        a.query(%{DROP TABLE IF EXISTS event})
        b.query(%{CREATE TABLE event (id INT PRIMARY KEY NOT NULL AUTO_INCREMENT, created_on DATE, what VARCHAR(50))})

        a.query(%{INSERT INTO event(created_on, what) values('2005-03-27', 'order')})
        a.insert_id.should eq(1)

        b.query(%{INSERT INTO event(created_on, what) values('2005-04-05', 'shipment')})
        b.insert_id.should eq(2)

        a.close
        b.close

        a = pool.get_connection
        b = pool.get_connection

        a.query(%{INSERT INTO event(created_on, what) values('2005-06-14', 'return')})
        a.insert_id.should eq(3)

        b.query(%{SELECT * FROM event})
         .should eq([
          [1, Time::Format.new("%F").parse("2005-03-27"), "order"],
          [2, Time::Format.new("%F").parse("2005-04-05"), "shipment"],
          [3, Time::Format.new("%F").parse("2005-06-14"), "return"],
        ])

        a.close
        b.close
      end
    end
  end
end
