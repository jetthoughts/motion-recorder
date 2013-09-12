class AppDelegate
  attr_reader :window
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    cookie_and_exception_handling

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    controller = VideosViewController.alloc.initWithNibName(nil, bundle: nil)
    nav_controller = UINavigationController.alloc.initWithRootViewController(controller)
    Video.load
    @window.rootViewController = nav_controller
    true
  end
 
  def has_internet?
    Reachability.reachabilityForInternetConnection.isReachable
  end


  private

  def cookie_and_exception_handling
    TestFlight.takeOff("b4ab9455-0e67-44f7-8fc7-9d9c34176c86")
    
    cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage
    cookieStorage.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever
    
    handler = lambda do |exception|
      NSLog("Crash #{exception.inspect}")
      NSLog("Stack Trace #{exception.callStackSymbols}")
    end
    NSSetUncaughtExceptionHandler(handler)
  end

end
