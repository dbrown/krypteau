require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe "krypteaukeys/index" do

  before( :each ) do
      @controller = Krypteaukeys.new( fake_request )
      @krypteaukeys = [Krypteaukey.create( :name => "stupidtestket", :created_at => Time.now ), Krypteaukey.create( :name => "cooltestkey", :created_at => Time.now )]
      @controller.instance_variable_set( :@krypteaukeys, @krypteaukeys)
      @name = @controller.render( :index )
  end

  it "should have a containing div for the krypteaukeys" do
      @name.should have_selector( "div#krypteaukeys.container" )
  end

  it "should have a div for each individual krypteaukey" do
      @krypteaukeys.each do |krypteaukey| 
        @name.should have_selector( "div#krypteaukeys.container div#krypteaukey-#{ krypteaukey.id }.krypteaukey" )
      end
  end

  it "should have the contents of each krypteaukey inside a div with an id and class" do
      @krypteaukeys.each do |krypteaukey|
        @name.should match_tag( :div, :id => "krypteaukey-#{ krypteaukey.id }", :class => "krypteaukey", :content => krypteaukey.name )
      end
  end

  after( :each ) do
      Krypteaukey.destroy_all
  end

end
