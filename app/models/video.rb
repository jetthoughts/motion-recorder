class Video
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter # <== Here!

  FILE_NAME =  'videos.dat'
  columns created_at: :date, name: :string, duration: :float, was_uploaded: :boolean, was_notified: :boolean
  attr_accessor :processing

  def init    
    super
  end

  def self.createWithUrl url
    if url
      v = Video.new
      v.created_at = Time.now
      if NSFileManager.defaultManager.copyItemAtURL(url, toURL: v.local_url, error:nil)
        v.save
        Video.store 
      end
    end
  end

  def before_create sender
    #calculate_duration
  end

  #Doesnt works for me
  def after_save sender

    #Video.store
  end

  def key
    @key ||= 'movie_' + self.created_at.to_i.to_s + '.mov'
  end 

  def local_url
    if @local_url.nil? && !self.created_at.nil?
      documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, true).objectAtIndex(0)
      destinationPath = documentsDirectory.stringByAppendingString('/' + self.key)       
      @local_url ||= NSURL.fileURLWithPath(destinationPath)
    end
    @local_url
  end

  def send_notify_request url
    files = {}
    if (thumbnail = self.thumbnails.first)      
      files[:thumbnail] = { data: UIImagePNGRepresentation(thumbnail), filename: (self.key + '.png') }
    end
    BW::HTTP.post(NOTIFY_URL, files: files, payload: {message: "This is a comment", url: url, key: self.key}) do |response|
      on_notified
    end
  end

  def notify
    return unless UIApplication.sharedApplication.delegate.has_internet?
    self.processing = true
    AmazonUploader.instance.getLink(self.key) do |url|
       p 'receive link'
       p url
       send_notify_request url
    end  
  end

  def on_notified
    self.processing = false
    self.was_notified = true
    self.save
    Video.store
  end  
  
  def on_upload
    self.processing = false
    self.was_uploaded = true
    self.save
    Video.store
    self.notify
  end

  def processed?
    was_uploaded && was_notified
  end

  def process
    return if self.processed?

    if self.was_uploaded
      notify
    else
      upload
    end  

  end  

  def upload
    return if self.was_uploaded

    uploader = AmazonUploader.instance
    if UIApplication.sharedApplication.delegate.has_internet?
      self.processing = true
      uploader.upload self
    else
      App.alert  "Can't upload now"
    end  
  end 

  def thumbnails
    @thumbnails ||= [makeThumbFromVideo(2.0), makeThumbFromVideo(3.0),  makeThumbFromVideo(2.0)].compact
  end   

  def self.load
    Video.deserialize_from_file(FILE_NAME)    
  end

  def self.store
    Video.serialize_to_file(FILE_NAME)
  end  
  
  #TODO: try on real device
  def duration_alternatice
    playerItem = AVPlayerItem.playerItemWithURL selectedVideoUrl

    duration = playerItem.duration
    CMTimeGetSeconds(duration)
  end  

  def player
     if @player.nil?
       @player = MPMoviePlayerController.alloc.initWithContentURL self.local_url    
     end
    @player
  end

  def calculate_duration
    if !self.duration && !self.local_url.nil?
      player.prepareToPlay
      NSNotificationCenter.defaultCenter.addObserver self, selector: 'movieDurationAvailable:', name: MPMovieDurationAvailableNotification, object: player   
    end
  end  

  def movieDurationAvailable notification  
    NSNotificationCenter.defaultCenter.removeObserver(self, name:"movieDurationAvailable", object:nil)
    p '******'
    self.duration = player.duration   
    p self
    self.save
  end

  private

  def makeThumbFromVideo position     
    thumbnail = nil    
  #  if !self.duration.nil? && position < self.duration      
      thumbnail = player.thumbnailImageAtTime position, timeOption: MPMovieTimeOptionNearestKeyFrame
      #player.stop
   # end
    thumbnail
  end    
  
end
