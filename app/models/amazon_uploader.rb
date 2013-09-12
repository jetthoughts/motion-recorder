class AmazonUploader

  CONTENT_TYPE = 'video/mov'

  def self.instance
    @@instance ||= AmazonUploader.alloc.init
  end

  def init
    @s3 = AmazonS3Client.alloc.initWithAccessKey(S3_ACCESS_KEY_ID, withSecretKey: S3_SECRET_KEY)
    @ready = true
    super
  end

  def ready?
    @ready
  end

   def getLink key, &block
    Dispatch::Queue.concurrent.async do
      request = S3GetPreSignedURLRequest.new.tap do |r|
        r.key     = key
        r.bucket  = S3_BUCKET
        r.expires = NSDate.dateWithTimeIntervalSinceNow(86400000)
        r.responseHeaderOverrides = S3ResponseHeaderOverrides.new.tap { |o| o.contentType = CONTENT_TYPE }
      end

      err = Pointer.new(:object)
      url = @s3.getPreSignedURL(request, error:err)

      Dispatch::Queue.main.sync do
        if (url == nil)
          if (error[0] != nil)
            alert(error[0])
          end
        else
          block.call(url.absoluteString)
        end
      end
    end
  end

  #def request(request, didSendData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
  # p '*******'
  # p bytesWritten
  # p totalBytesWritten
  # p totalBytesExpectedToWrite
  #end

  def upload movie

   UIApplication.sharedApplication.setNetworkActivityIndicatorVisible(true)
    Dispatch::Queue.concurrent.async do
      req = S3PutObjectRequest.alloc.initWithKey(movie.key, inBucket: S3_BUCKET).tap do |r|
        r.contentType = CONTENT_TYPE
        r.data = NSData.dataWithContentsOfURL movie.local_url
      end

      response = @s3.putObject(req)

      Dispatch::Queue.main.sync do
        UIApplication.sharedApplication.setNetworkActivityIndicatorVisible(false)
        if response
        if (response.error != nil)
          alert(response.error)
        else
          p 'Calling ON UPLOAD'
          movie.on_upload
        end
      end

      end
    end
  end
end
