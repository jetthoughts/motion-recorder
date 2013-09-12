class  PlayerViewCell < UITableViewCell
  attr_accessor :imageView, :player
  VIDEO_SIZE = 300
  def initWithURL url, reuseIdentifier
    self.initWithStyle(UITableViewStylePlain, reuseIdentifier:reuseIdentifier)
    self.setSelectionStyle UITableViewCellSelectionStyleNone
    #self.backgroundView = UIView.alloc.init
    #self.backgroundView.backgroundColor = UIColor.redColor
    @player = MPMoviePlayerController.alloc.initWithContentURL url
    @player.shouldAutoplay = false
    @player.view.frame = CGRectMake((self.frame.size.width - VIDEO_SIZE)/2, 10, VIDEO_SIZE, VIDEO_SIZE)   
    self.addSubview(@player.view)  
    @player.prepareToPlay  
  	self
  end	

  def self.height
    VIDEO_SIZE + 10
  end

end	