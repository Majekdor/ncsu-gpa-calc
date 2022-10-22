//
//  Course.swift
//  AppDevClubGpaCalcSwiftUI
//
//  Created by Kevin Barnes on 10/17/22.
//

import Foundation

/// Represents a course the user is taking this semester.
struct Course: Hashable {
    /// The name of the course.
    var name: String
    /// How many credit hours the course is worth.
    var creditHours: Int
    /// The grade (0-100) the user received in the course.
    var grade: Double
}
