//
//  MusicApp.swift
//  Music Bar
//
//  Created by Musa Semou on 25/11/2019.
//  Copyright © 2019 Musa Semou. All rights reserved.
//

import Foundation
import AppKit

class MusicApp {
    static let shared = MusicApp()
    
    // MARK: - Properties
    var isRunning: Bool {
        if let app = NSRunningApplication.get(withBundleIdentifier: "com.apple.Music") {
            return app.isRunning
        }
        
        return false
    }
	
	var isPlaying: Bool = false {
		didSet {
			if oldValue != isPlaying {
				NotificationCenter.post(name: .PlayerStateDidChange)
			}
		}
	}
	
    var currentPlayerPosition: Int = 0 {
		didSet {
			if oldValue != currentPlayerPosition {
				NotificationCenter.post(name: .PlayerPositionDidChange)
			}
		}
	}
	
	var currentTrack: Track? {
		didSet {
			// Check if the new track is different than the previous one
			if oldValue != currentTrack {
				// Update artwork when a new track is detected
				updateArtwork(forTrack: currentTrack)
			}
			
			// Post notification
			NotificationCenter.post(name: .TrackDataDidChange)
		}
	}
	
	var artwork: NSImage? {
		didSet {
			NotificationCenter.post(name: .ArtworkDidChange)
			
			// Update average color
			if artwork == nil {
				artworkColor = nil
			}
			else {
				artworkColor = artwork?.averageColor
				
				// If the artwork color is not light enough, we lighten it to ensure visibility
				if let isLight = artworkColor!.isLight(), !isLight {
					artworkColor = artworkColor!.highlight(withLevel: 0.2)!
				}
			}
		}
	}
	
	var artworkColor: NSColor?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Functions
    // Go to the previous track or the beginning of the current track
    func backTrack() {
        NSAppleScript.run(code: NSAppleScript.snippets.BackTrack.rawValue, completionHandler: {_,_,_ in })
    }
    
    // Go to the next track
    func nextTrack() {
        NSAppleScript.run(code: NSAppleScript.snippets.NextTrack.rawValue, completionHandler: {_,_,_ in })
    }

    // Pause or play the current track
    func pausePlay() {
        NSAppleScript.run(code: NSAppleScript.snippets.PausePlay.rawValue, completionHandler: {_,_,_ in })
    }
    
    // Set the player position to a timestamp (seconds)
    func setPlayerPosition(_ position: Int) {
        NSAppleScript.run(code: NSAppleScript.snippets.SetCurrentPlayerPosition(position), completionHandler: {_,_,_ in })
    }
    
    // Uses AppleScript to update data
    func updateData() {
        if isRunning {
            // Update player status
            NSAppleScript.run(code: NSAppleScript.snippets.GetCurrentPlayerState.rawValue) { (success, output, errors) in
                if success {
                    self.isPlaying = (output!.data.stringValue == "playing")
                }
            }
            
            // Update current track
            NSAppleScript.run(code: NSAppleScript.snippets.GetCurrentTrackProperties.rawValue) { (success, output, errors) in
                if success {
					// Get the new track
					let newTrack = Track(fromList: output!.listItems())
					
                    // Set the current track
					currentTrack = newTrack
                }
				else {
					currentTrack = nil
				}
            }
            
            // Update player position
            NSAppleScript.run(code: NSAppleScript.snippets.GetCurrentPlayerPosition.rawValue) { (success, output, errors) in
                if success {
                    var newPosition = Double(output!.cleanDescription) ?? 0
                    newPosition.round(.down)

                    self.currentPlayerPosition = Int(newPosition)
                }
            }
        }
    }
	
	// Retrieves the artwork of the current track
	fileprivate func updateArtwork(forTrack track: Track?) {
		// Post ArtworkWillChange notification
		NotificationCenter.post(name: .ArtworkWillChange)
		
		if track == nil {
			self.artwork = PlayerViewController.defaultAlbumCover
			return
		}
		
		// Retrieve artwork from Apple Music
		DispatchQueue.main.async {
			NSAppleScript.run(code: NSAppleScript.snippets.GetCurrentArtwork.rawValue) { (success, output, errors) in
				if success {
					self.artwork = NSImage(data: output!.data)
				}
				else {
					self.artwork = PlayerViewController.defaultAlbumCover
				}
			}
		}
	}
}
