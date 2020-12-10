//
//  ViewController.swift
//  Music Bar
//
//  Created by Musa Semou on 24/11/2019.
//  Copyright © 2019 Musa Semou. All rights reserved.
//

import Cocoa
import ScriptingBridge
import IOBluetooth

class PlayerViewController: NSViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var albumImage: NSImageView!
	@IBOutlet weak var preferencesButton: NSButton!
	@IBOutlet weak var playPauseButton: NSButton!
	@IBOutlet weak var forwardButton: NSButton!
	@IBOutlet weak var backwardButton: NSButton!
	@IBOutlet weak var playbackSlider: NSSlider!
	@IBOutlet var controlsOverlay: NSView!
	@IBOutlet weak var currentPlayerPositionTextField: NSTextField!
	@IBOutlet weak var totalDurationTextField: NSTextField!

	// MARK: - Properties
	static let playButtonImage: NSImage = NSImage(imageLiteralResourceName: "Symbols/play.fill")
	static let pauseButtonImage: NSImage = NSImage(imageLiteralResourceName: "Symbols/pause.fill")
	static let defaultAlbumCover: NSImage = NSImage(imageLiteralResourceName: "default-album-cover")
	static let loadingAlbumCover: NSImage = NSImage(imageLiteralResourceName: "loading-album-cover")
	var musicAppChangeObservers: [NSObjectProtocol] = []

	// MARK: - View
	override func viewWillAppear() {
		super.viewWillAppear()

		// Update initial view data
		if let track = MusicApp.shared.currentTrack {
			updateView(with: track)
		}

		updatePlayerStatus(playing: MusicApp.shared.isPlaying)
		updateAlbumImage(withImage: MusicApp.shared.artwork)
		setPlaybackSliderPosition(to: MusicApp.shared.currentPlayerPosition)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configureShadows()
		addMouseTrackingArea()
		addMusicAppChangeObservers()
	}

	override func viewDidDisappear() {
		removeMusicAppChangeObservers()
	}

	// MARK: - IBActions
	@IBAction func backButtonPressed(_ sender: Any) {
		MusicApp.shared.backTrack()
	}

	@IBAction func nextButtonPressed(_ sender: Any) {
		MusicApp.shared.nextTrack()
	}

	@IBAction func playbackSliderMoved(_ sender: Any) {
		let newTimestamp = playbackSlider.intValue

		MusicApp.shared.setPlayerPosition(Int(newTimestamp))
	}

	@IBAction func pausePlayButtonPressed(_ sender: Any) {
		MusicApp.shared.pausePlay()
	}

	@IBAction func openPreferencesButtonPressed(_ sender: Any) {
		// Instantiate the window, if not already done
		if AppDelegate.preferencesWindow == nil {
			let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
			AppDelegate.preferencesWindow = mainStoryboard.instantiateController(withIdentifier: "PreferencesWindowController") as? PreferencesWindowController
		}

		// Show the window
		if let window = AppDelegate.preferencesWindow {
			window.showWindow(self)
			window.window?.center()
		}

		// Focus on preferences window
		NSApp.activate(ignoringOtherApps: true)
	}

	// MARK: - Functions
	/**
		Configures button shadows.
	*/
	fileprivate func configureShadows() {
		addShadow(to: preferencesButton)
		addShadow(to: playPauseButton)
		addShadow(to: forwardButton)
		addShadow(to: backwardButton)
	}

	/**
		Adds a nice shadow to the given view.

		- Parameter view: The view to which the shadow is applied.
	*/
	fileprivate func addShadow(to view: NSView) {
		let shadow = NSShadow()
		shadow.shadowColor = .black
		shadow.shadowBlurRadius = 4
		shadow.shadowOffset = .zero
		view.shadow = shadow
	}

	fileprivate func addMouseTrackingArea() {
		let trackingArea = NSTrackingArea(rect: self.view.accessibilityFrame(), options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		self.view.addTrackingArea(trackingArea)
	}

	fileprivate func addMusicAppChangeObservers() {
		// Add TrackDataDidChange observer
		musicAppChangeObservers.append(
			NotificationCenter.observe(name: .TrackDataDidChange) {
				self.updateView(with: MusicApp.shared.currentTrack)
			}
		)

		// Add PlayerStateDidChange observer
		musicAppChangeObservers.append(
			NotificationCenter.observe(name: .PlayerStateDidChange) {
				self.updatePlayerStatus(playing: MusicApp.shared.isPlaying)
			}
		)

		// Add PlayerPositionDidChange observer
		musicAppChangeObservers.append(
			NotificationCenter.observe(name: .PlayerPositionDidChange) {
				self.setPlaybackSliderPosition(to: MusicApp.shared.currentPlayerPosition)
			}
		)

		// Add ArtworkWillChange observer
		musicAppChangeObservers.append(
			NotificationCenter.observe(name: .ArtworkWillChange) {
				self.updateAlbumImage(withImage: PlayerViewController.loadingAlbumCover)
			}
		)

		// Add ArtworkDidChange observer
		musicAppChangeObservers.append(
			NotificationCenter.observe(name: .ArtworkDidChange) {
				self.updateAlbumImage(withImage: MusicApp.shared.artwork)
			}
		)
	}

	fileprivate func removeMusicAppChangeObservers() {
		for observer in musicAppChangeObservers {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	override func mouseEntered(with event: NSEvent) {
		controlsOverlay.isHidden = false
	}

	override func mouseExited(with event: NSEvent) {
		controlsOverlay.isHidden = true
	}

	// Updates the view according to the information in the given track.
	func updateView(with newTrack: Track?) {
		if let track = newTrack {
			totalDurationTextField.stringValue = track.duration.durationString
			playbackSlider.maxValue = Double(track.duration)
			
			totalDurationTextField.isHidden = false
			currentPlayerPositionTextField.isHidden = false
			playbackSlider.isHidden = false
		}
		else {
			totalDurationTextField.isHidden = true
			currentPlayerPositionTextField.isHidden = true
			playbackSlider.isHidden = true
		}
	}

	// Updates the album image with a new image
	func updateAlbumImage(withImage image: NSImage?) {
		if let artwork = image {
			self.albumImage.image = artwork
		}
		else {
			self.albumImage.image = PlayerViewController.defaultAlbumCover
		}
	}

	// Updates the slider position to the given seconds
	func setPlaybackSliderPosition(to seconds: Int) {
		self.playbackSlider.intValue = Int32(seconds)
		self.currentPlayerPositionTextField.stringValue = seconds.durationString
	}

	// Updates the player status according to whether or not music is playing.
	func updatePlayerStatus(playing: Bool) {
		if playing {
			playPauseButton.image = PlayerViewController.pauseButtonImage
		}
		else {
			playPauseButton.image = PlayerViewController.playButtonImage
		}
	}
}
