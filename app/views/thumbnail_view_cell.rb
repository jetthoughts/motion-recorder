class  ThumbnailViewCell < UITableViewCell
  attr_accessor :imageView

  def initWithThumbnail reuseIdentifier
    self.initWithStyle(UITableViewStylePlain, reuseIdentifier:reuseIdentifier)
    self.setSelectionStyle UITableViewCellSelectionStyleNone
    #self.backgroundView = UIView.alloc.init
    #self.backgroundView.backgroundColor = UIColor.redColor
    self.imageView = UIImageView.alloc.initWithFrame([[(self.frame.size.width - Thumbnail::DISPLAY_SIZE.first)/2,0], Thumbnail::DISPLAY_SIZE] )    
    self.addSubview(self.imageView)    
  	self
  end	

  def self.height
    Thumbnail::DISPLAY_SIZE.last + 10
  end

end	