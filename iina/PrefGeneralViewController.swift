//
//  PrefGeneralViewController.swift
//  iina
//
//  Created by lhc on 27/10/2016.
//  Copyright © 2016 lhc. All rights reserved.
//

import Cocoa
import Sparkle

@objcMembers
class PrefGeneralViewController: PreferenceViewController, PreferenceWindowEmbeddable {

  override var nibName: NSNib.Name {
    return NSNib.Name("PrefGeneralViewController")
  }

  var preferenceTabTitle: String {
    return NSLocalizedString("preference.general", comment: "General")
  }

  var preferenceTabImage: NSImage {
    return .sf("gear", withConfiguration: symbolConfiguration)!
  }

  override var sectionViews: [NSView] {
    return [behaviorView, historyView, playlistView, screenshotsView]
  }

  @IBOutlet var behaviorView: NSView!
  @IBOutlet var historyView: NSView!
  @IBOutlet var playlistView: NSView!
  @IBOutlet var screenshotsView: NSView!
  @IBOutlet weak var afterOpenActionBox: NSBox!
  @IBOutlet weak var pauseActionBox: NSBox!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    afterOpenActionBox.heightAnchor.constraint(equalToConstant: 42).isActive = true
    pauseActionBox.heightAnchor.constraint(equalToConstant: 146).isActive = true
    addCameraHousingFullScreenOption()
  }

  private func addCameraHousingFullScreenOption() {
    guard let legacyFullScreenButton = findControl(in: behaviorView, boundTo: Preference.Key.useLegacyFullScreen.rawValue) else {
      return
    }

    let button = NSButton(
      checkboxWithTitle: "Fill screen around camera housing",
      target: nil,
      action: nil
    )
    button.translatesAutoresizingMaskIntoConstraints = false
    button.controlSize = legacyFullScreenButton.controlSize
    button.bind(
      .value,
      to: UserDefaults.standard,
      withKeyPath: Preference.Key.legacyFullScreenExtendIntoCameraHousing.rawValue
    )
    button.bind(
      .enabled,
      to: UserDefaults.standard,
      withKeyPath: Preference.Key.useLegacyFullScreen.rawValue
    )

    behaviorView.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: legacyFullScreenButton.trailingAnchor, constant: 12),
      button.centerYAnchor.constraint(equalTo: legacyFullScreenButton.centerYAnchor),
      button.trailingAnchor.constraint(lessThanOrEqualTo: behaviorView.trailingAnchor, constant: -8)
    ])
  }

  private func findControl(in view: NSView, boundTo keyPath: String) -> NSControl? {
    if let control = view as? NSControl,
       let bindingInfo = control.infoForBinding(.value),
       bindingInfo[.observedKeyPath] as? String == "values.\(keyPath)" {
      return control
    }

    for subview in view.subviews {
      if let control = findControl(in: subview, boundTo: keyPath) {
        return control
      }
    }
    return nil
  }
  
  // MARK: - IBAction

  @IBAction func chooseScreenshotPathAction(_ sender: AnyObject) {
    Utility.quickOpenPanel(title: "Choose screenshot save path", chooseDir: true, sheetWindow: view.window) { url in
      Preference.set(url.path, for: .screenshotFolder)
      UserDefaults.standard.synchronize()
    }
  }

  @IBAction func rememberRecentChanged(_ sender: NSButton) {
    if sender.state == .off {
      AppDelegate.shared.clearRecentDocuments(self)
    }
  }
}

