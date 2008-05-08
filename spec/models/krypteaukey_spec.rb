require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Krypteaukey do

  it "should be valid when new" do
    key = Krypteaukey.new
    key.should be_valid
  end

end
