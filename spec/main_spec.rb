describe "Application 'MotionRecorder'" do
  before do
    @app = UIApplication.sharedApplication
  end

  it "has one window" do
    @app.windows.size.should == 10
  end
end
