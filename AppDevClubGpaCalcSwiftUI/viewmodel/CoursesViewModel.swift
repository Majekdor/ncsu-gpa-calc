//
//  CoursesViewModel.swift
//  AppDevClubGpaCalcSwiftUI
//
//  Created by Kevin Barnes on 10/17/22.
//

import Foundation

/// StateObject for variables needed in adding courses.
class CoursesViewModel: ObservableObject {
    
    /// Shared singleton instance of the view model.
    static let shared = CoursesViewModel()
    
    /// The courses the user is taking this semester.
    @Published var courses: [Course] = []
    /// Whether the sheet for adding a course should be shown.
    @Published var showAddCourseSheet: Bool = false
}
