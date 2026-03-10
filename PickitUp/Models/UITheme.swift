//
//  UITheme.swift
//  PickitUp
//
//  Created by Burak Demirhan on 10/03/26.
//

import Foundation
import SwiftUI

enum UITheme {

    // MARK: Core Colors

    static let primary = Color(red: 0.12, green: 0.12, blue: 0.18)

    static let denim = Color(red: 0.25, green: 0.50, blue: 0.76)

    static let surface = Color.white

    static let surfaceSoft = Color.white.opacity(0.15)

    static let surfaceGlass = Color.white.opacity(0.25)

    // MARK: Text

    static let textPrimary = Color.primary

    static let textSecondary = Color.secondary

    static let textOnDark = Color.white

    // MARK: Status Colors

    static let success = Color.green

    static let warning = Color.orange

    static let info = Color.blue

    // MARK: Chips

    static let chipBackground = Color(.systemGray6)

    static let chipSelectedBackground = primary

    static let chipText = Color.primary

    static let chipSelectedText = Color.white

    // MARK: Buttons

    static let buttonPrimaryBackground = primary

    static let buttonPrimaryText = Color.white

    static let buttonSecondaryBackground = Color.white.opacity(0.5)

}
