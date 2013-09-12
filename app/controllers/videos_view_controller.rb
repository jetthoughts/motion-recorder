class VideosViewController < UITableViewController

  def viewDidLoad
    self.view.backgroundColor = UIColor.whiteColor
    self.title = 'Videos'
    right_button = UIBarButtonItem.alloc.initWithTitle('Add New', style: UIBarButtonItemStyleBordered, target:self, action:'create')
    self.navigationItem.rightBarButtonItem = right_button
    @videos_change_observer = App.notification_center.observe MOTION_MODEL_DATA_DID_CHANGE_NOTIFICATIONS do |notification|
      if notification.object.is_a?(Video)
        loadData
      end
    end
    loadData
  end  

  CellID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellID)
    video = @videos[indexPath.row]
    cell.textLabel.text = video.key    
   # cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton
    cell.imageView.setImage(UIImage.imageNamed( video.processed? ? 'done.png' : 'initial.png'))
    cell
  end
  
  def tableView(tableView,numberOfRowsInSection:section)
    @videos.count
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    video = @videos[indexPath.row]
    controller = ShowVideoViewController.alloc.initWithVideo video
    self.navigationController.pushViewController(controller, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end
  
  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    url = info.objectForKey UIImagePickerControllerMediaURL 
    self.dismissModalViewControllerAnimated(true)   

    video = Video.createWithUrl url
    loadData if video  
  end

  private

  def create
    return show_alert unless camera_present
    image_picker = UIImagePickerController.alloc.init
    image_picker.delegate = self
    image_picker.allowsEditing = true
    image_picker.sourceType = UIImagePickerControllerSourceTypeCamera
    image_picker.mediaTypes = [KUTTypeMovie]
    presentModalViewController(image_picker, animated:true)
  end

  def show_alert
    App.alert  'No Camera in device'
  end

  def loadData
    @videos = Video.all
    self.view.reloadData
  end

  def camera_present
    UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
  end

end
