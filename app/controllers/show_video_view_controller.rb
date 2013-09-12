class ShowVideoViewController < UIViewController
  CELL_ID = 'CellIdentifier'
  PLAYER_CELL_ID = 'PlayerCellIdentifier'
  BAR_HEIGHT = 44
  def initWithVideo video
    @video = video
    init
  end

  def viewDidLoad
    self.title = @video.key
    self.view.backgroundColor = UIColor.whiteColor
    @mail_button = BW::UIBarButtonItem.styled(:plain, 'Mail') do
      AmazonUploader.instance.getLink(@video.key) do |url|
        sendMailWithLink url
      end
    end

    toolbar = UIToolbar.alloc.initWithFrame [[0, self.view.frame.size.height - BAR_HEIGHT * 2], [320, BAR_HEIGHT]]
    self.view.addSubview(toolbar)
    toolbar.setItems([@mail_button], animated:false)

    @thumbnails_table = UITableView.alloc.initWithFrame([[0,0], [self.view.frame.size.width, self.view.frame.size.height - BAR_HEIGHT * 2]])
    self.view.addSubview @thumbnails_table
    @thumbnails_table.dataSource = self
    @thumbnails_table.delegate = self

    @right_button = UIBarButtonItem.alloc.initWithTitle('Upload', style: UIBarButtonItemStyleBordered, target:self, action: 'upload')
    self.navigationItem.rightBarButtonItem = @right_button

    @video_change_observer = App.notification_center.observe MOTION_MODEL_DATA_DID_CHANGE_NOTIFICATIONS do |notification|
      self.updateViews if notification.object === @video
    end

    updateViews
  end

  def updateViews

    @right_button.enabled = !(@video.processed? || @video.processing)
    @mail_button.enabled = @video.was_uploaded
    @right_button.title = @video.processing ? 'Uploading...' : 'Upload'
  end

  def viewWillDisappear(animated)
    App.notification_center.unobserve @video_change_observer
  end

  def upload
    @video.process
    updateViews
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    index = indexPath.row
    if index > 0
      cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID)
      cell ||= ThumbnailViewCell.alloc.initWithThumbnail(CELL_ID)
      thumb = @video.thumbnails[index - 1]
      cell.imageView.image = thumb
      cell
    else
      cell = tableView.dequeueReusableCellWithIdentifier(PLAYER_CELL_ID)
      cell ||= PlayerViewCell.alloc.initWithURL(@video.local_url, PLAYER_CELL_ID)
      cell
    end
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    @video.thumbnails.count + 1  
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.row > 0
      ThumbnailViewCell.height
    else
      PlayerViewCell.height
    end
  end        
   
  def mailComposeController controller, didFinishWithResult: result, error:error
    case result
    when MFMailComposeResultSent
      App.alert 'Mail was sent'
    when MFMailComposeResultFailed
        App.alert 'Mail failed to send'
    end
    self.dismissModalViewControllerAnimated true
  end

  private

  def sendMailWithLink(link)
     # BW::Mail.compose({ subject: 'New video', message: 'Likn:' + link }) do |result, error|
     #    App.alert  result.sent? ? 'Url was sent' : 'Sorry. Try again'           
     #end
      mailer = MFMailComposeViewController.alloc.init
      mailer.setSubject 'New video recorded'
      mailer.setMessageBody "<a href='#{link}'>Link to new video</a>", isHTML: true
      mailer.mailComposeDelegate = self
      self.presentModalViewController mailer, animated: true
  end

end
