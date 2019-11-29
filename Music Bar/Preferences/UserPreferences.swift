//
//  UserPreferences.swift
//  Music Bar
//
//  Created by Musa Semou on 27/11/2019.
//  Copyright © 2019 Musa Semou. All rights reserved.
//

import Foundation

class UserPreferences {
	// MARK: - Enums
	private enum Keys: String {
		case appearance
		case artworkQuality
		case startAppAtLogin
	}
	
	enum AppearanceMode: String {
		case light, dark, auto
	}
	
	enum ArtworkQualityMode: String {
		case low, normal, high
	}
	
	// MARK: - Class vars
	class var appearance: AppearanceMode {
        get {
			return self.AppearanceMode.init(rawValue:
				self.readString(fromKey: self.Keys.appearance.rawValue) ?? ""
			) ?? self.AppearanceMode.auto
        }
        set {
			self.write(value: newValue.rawValue, toKey: self.Keys.appearance.rawValue)
        }
    }
	
	class var artworkQuality: ArtworkQualityMode {
        get {
			return self.ArtworkQualityMode.init(rawValue:
				self.readString(fromKey: self.Keys.artworkQuality.rawValue) ?? ""
				) ?? self.ArtworkQualityMode.normal
        }
        set {
			self.write(value: newValue.rawValue, toKey: self.Keys.artworkQuality.rawValue)
        }
    }
	
	class var startAppAtLogin: Bool {
        get {
			return self.readBool(fromKey: self.Keys.startAppAtLogin.rawValue) ?? true
        }
        set {
			self.write(value: newValue, toKey: self.Keys.startAppAtLogin.rawValue)
        }
    }
	
	// MARK: - Functions
	private static func write(value: Any?, toKey key: String) {
		UserDefaults.standard.set(value, forKey: key)
	}
	
	private static func readString(fromKey key: String) -> String? {
		return UserDefaults.standard.string(forKey: key)
	}
	
	private static func readBool(fromKey key: String) -> Bool? {
		return UserDefaults.standard.bool(forKey: key)
	}
}
