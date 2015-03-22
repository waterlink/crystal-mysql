require "../spec_helper"

module MySQL
  describe Support do
    describe ".escape_string" do
      it "provides protection from nasty queries" do
        Support.escape_string("'; DROP TABLE users; --").should eq("\\'; DROP TABLE users; --")
      end
    end
  end
end
