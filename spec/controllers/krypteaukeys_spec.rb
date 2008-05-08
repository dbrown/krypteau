require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Krypteaukeys, "index action" do
  it "should respond correctly" do
      dispatch_to( Krypteaukeys, :index ).should respond_successfully
  end
end
