# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion2.6/lib")
require 'motion/project/template/ios'
require 'bundler'
require 'rubygems'
require 'motion-cocoapods'
require 'motion-testflight'
require 'motion_model'
require 'bubble-wrap/all'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionRecorder'
  app.identifier = 'com.jetthoughts.MotionRecorder'
  app.version = `git log -n 1 --pretty=format:'%h'`.upcase
  app.short_version = '1.0'
  app.frameworks += ['CoreData', 'MediaPlayer', 'CoreMedia', 'AVFoundation', 'MessageUI', 'MFMailComposeViewController']

  # Distribution - use rake archive:distribution
  app.release do
    app.codesign_certificate = 'iPhone Distribution: Michael Nikitochkin'
    app.provisioning_profile('MotionRecorder AdHoc')
    app.entitlements['get-task-allow'] = false
  end

  # Development - use rake archive
  app.development do
    app.codesign_certificate = 'iPhone Distribution: Michael Nikitochkin'
    app.provisioning_profile('MotionRecorder AdHoc')
    app.entitlements['get-task-allow'] = true

    app.testflight do
      app.entitlements['get-task-allow'] = false
      app.testflight.api_token  = 'b256ba44141243c21618b86ad8ca6730_MjU0MDQyMjAxMS0xMi0xOSAwNDoxMTo1MC43MTU1OTI'
      app.testflight.team_token = 'c373ef0c769822b39cd42b806fe39372_Njc1NzUyMDEyLTA3LTA2IDA5OjE0OjE4LjQ0NjY5OA'
      app.testflight.app_token  = 'b4ab9455-0e67-44f7-8fc7-9d9c34176c86'
      app.testflight.notify = true # default is false
      app.testflight.identify_testers = true # default is false
      app.testflight.distribution_lists = ['MotionRecorder']
    end
  end

  app.testflight.sdk = 'vendor/TestFlightSDK2.0.0'

  app.deployment_target = '5.0'
  app.interface_orientations = [:portrait]
  
  app.icons = %w[Default-568h@2x.png Icon.png Icon-72.png Icon-76.png Icon-76@2x.png Icon@x2.png Icon-144.png]

  app.pods do
    pod 'AWSiOSSDK'
    pod 'Reachability'
  end 
end
