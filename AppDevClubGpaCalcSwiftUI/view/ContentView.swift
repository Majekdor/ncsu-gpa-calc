//
//  ContentView.swift
//  AppDevClubGpaCalcSwiftUI
//
//  Created by Kevin Barnes on 10/17/22.
//

import SwiftUI

/// The main view that will be shown when the app is opened.
struct ContentView: View {
    
    // Variables associated with the view.
    
    /// The user's current GPA before completion of the current semester.
    /// This is a string because it's bound to the text field where the user can input their GPA.
    /// It will be converted to a double later, with safeguards for if that fails.
    @State private var currentGpa: String = ""
    /// The user's number of credits taken before completion of the current semester.
    /// This is a string because it's bound to the text field where the user can input their number.
    /// It will be converted to an integer later, with safeguards for if that fails.
    @State private var creditsTaken: String = ""
    /// Whether the app should show an alert that the user's GPA couldn't be found.
    @State private var showGpaNotFoundAlert: Bool = false
    /// Whether the app should show an alert that the user's number of credits taken couldn't be found.
    @State private var showCreditsTakenNotFoundAlert: Bool = false
    /// View model that handles the user's semester classes and adding them.
    /// This is similar to the above states, but a state object can hold multiple values.
    @StateObject var coursesState: CoursesViewModel = CoursesViewModel.shared
    
    /// The user's calculated GPA after the semester has ended.
    @State private var gpa = 0.0
    /// Whether the app should show a sheet showing the user their calculated GPA.
    @State private var showCalculatedGpaSheet: Bool = false
    
    // The actual UI code for the view.
    var body: some View {
        // ScrollView can be better than VStack in a number of cases.
        // ScrollView will still stack items vertically similar to VStack.
        // VStack suffers from some issues associated with TextFields that ScrollView doesn't.
        ScrollView {
            Text("NCSU Gpa Calculator")
                .font(.title)
                .fontWeight(.bold)
                .underline(color: .red)
            
            // TODO: Add an info button saying what the app does.
            
            HStack {
                Text("Current GPA:")
                    .fontWeight(.semibold)
                
                // TODO: Limit entry to decimals only.
                TextField("0.0", text: self.$currentGpa)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done) // Will cause the 'return' key to display 'done' instead.
            }
            .frame(maxWidth: 300) // Limit how wide the HStack can be.
            
            HStack {
                Text("Credits Taken:")
                    .fontWeight(.semibold)
                
                // TODO: Limit entry to numbers only.
                TextField("0", text: self.$creditsTaken)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done) // Will cause the 'return' key to display 'done' instead.
            }
            .frame(maxWidth: 300) // Limit how wide the HStack can be.
            
            Text("Semester Classes")
                .padding(.top, 20) // Add extra padding or spacing above the text.
                .font(.title3)
                .fontWeight(.semibold)
                .offset(CGSize(width: 0.0, height: 10.0)) // Push the text down a little bit.
            
            // Put all of the semester classes in a list.
            List {
                // Create an entry in the list for each of the user's courses.
                // TODO: Make courses conform to Identifiable so that two courses could have the same name.
                ForEach(self.coursesState.courses, id: \.self) { course in
                    HStack {
                        VStack {
                            HStack {
                                Text("\(course.name)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                // Spacers take up all the space they can and result in pushing a view.
                                // In this case, since we're in an HStack, the text view above is pushed
                                // all the way to the left since it is listed first.
                                Spacer()
                            }
                            
                            HStack {
                                // TODO: Add a ternary for plurality check.
                                Text("\(course.creditHours) Credit Hours")
                                    .foregroundColor(.secondary) // Change the text color.
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        // Formatting a string is very similar to other languages.
                        Text("\(String(format: "%.2f", course.grade))")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    // Allow the user to delete a course by swiping from the trailing edge.
                    // TODO: Tell the user this is possible.
                    .swipeActions(edge: .trailing, content: {
                        // Button to delete the course.
                        Button(action: {
                            self.coursesState.courses.removeAll(where: {
                                $0.name == course.name
                            })
                        }, label: {
                            // This 'trash' symbol comes from SF Symbols. It's a separate app you can
                            // install and the symbols are all installed on iOS devices already.
                            Image(systemName: "trash")
                        })
                        .tint(.red)
                    })
                }
                
                // Additionally, add a button to the list that allows the user to add a course.
                VStack {
                    Button(action: {
                        // Show the sheet to add a course.
                        self.coursesState.showAddCourseSheet = true
                    }, label: {
                        HStack {
                            Spacer()
                            
                            // Spacers on either side result in the button sitting in the middle of the view.
                            Image(systemName: "plus")
                            
                            Spacer()
                        }
                    })
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .padding(.top, 20)
                    
                    // Include 'callout' text telling the user what the button does.
                    Text("Click the plus button to add a course.")
                        .italic()
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            // Hide the default background and make it white to match the rest of the app's background.
            .scrollContentBackground(.hidden)
            .background(.white)
            .frame(height: 450) // Set a max height for the list.
            
            // Button to calculate the user's GPA after the semester ends.
            Button(action: {
                // Ensure conversion works before continuing.
                guard let currentGpa = Double(self.currentGpa) else {
                    // Show the user an alert that their current GPA couldn't be found.
                    self.showGpaNotFoundAlert = true
                    return
                }
                // Ensure conversion works before continuing.
                guard let currentCredits = Double(self.creditsTaken) else {
                    // Show the user an alert that their current number of credits taken couldn't be found.
                    self.showCreditsTakenNotFoundAlert = true
                    return
                }
                
                // Calculate semester credit points and credit hours for each course.
                var semesterCreditPoints = 0.0
                var semesterCreditHours = 0
                for course in self.coursesState.courses {
                    let gradePoints = self.gradePointsFromNumericGrade(course.grade)
                    semesterCreditHours += course.creditHours
                    semesterCreditPoints += (Double(course.creditHours) * gradePoints)
                }
                
                // Calculate the user's GPA after the semester ends.
                self.gpa = ((currentGpa * currentCredits) + semesterCreditPoints) / (currentCredits + Double(semesterCreditHours))
                
                // Show the user a sheet that will display their calculated GPA.
                self.showCalculatedGpaSheet = true
            }, label: {
                Text("Calculate")
                    .fontWeight(.semibold)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.horizontal)
            
            Spacer() // Push everything in the ScrollView to the top.
        }
        .padding(.vertical)
        // The alert for the GPA not being found. This will be displayed when the associated state variable is true.
        .alert("Please enter your current GPA as a decimal. If you don't have one then enter 0.0.", isPresented: self.$showGpaNotFoundAlert, actions: {
            Button(role: .cancel, action: {
                // Button has no action, the `role: .cancel` takes care of dismissing the alert.
            }, label: {
                Text("Okay")
            })
        })
        // The alert for the credits taken not being found. This will be displayed when the associated state variable is true.
        .alert("Please enter your credits taken as a number. If you haven't taken any then enter 0.", isPresented: self.$showCreditsTakenNotFoundAlert, actions: {
            Button(role: .cancel, action: {
                // Button has no action, the `role: .cancel` takes care of dismissing the alert.
            }, label: {
                Text("Okay")
            })
        })
        // The sheet the user can use to add a course.
        .sheet(isPresented: self.$coursesState.showAddCourseSheet, content: {
            // I've intentionally passed state variables to these views in different ways. - Kevin
            AddCourseView()
                .environmentObject(self.coursesState) // Inject the view model into the view.
        })
        // The sheet the user can see their GPA in.
        .sheet(isPresented: self.$showCalculatedGpaSheet, content: {
            // I've intentionally passed state variables to these views in different ways. - Kevin
            CalculatedGpaView(
                showCalculatedGpaSheet: self.$showCalculatedGpaSheet, // Pass the needed state variables as bindings.
                gpa: self.$gpa
            )
        })
        // Code that should be run when the view initially appears.
        .onAppear {
            // Uncomment the below lines to have placeholder data in the preview
            //self.coursesState.courses.append(Course(name: "Class 1", creditHours: 3, grade: 96.6))
            //self.coursesState.courses.append(Course(name: "Class 2", creditHours: 3, grade: 94.2))
            //self.coursesState.courses.append(Course(name: "Class 3", creditHours: 4, grade: 95.4))
            //self.coursesState.courses.append(Course(name: "Class 4", creditHours: 3, grade: 84.9))
            //self.coursesState.courses.append(Course(name: "Class 5", creditHours: 1, grade: 86.1))
        }
    }
    
    /// Calculate the grade point based on the numeric grade.
    /// Ex. A 98 is an A+ and translates to 4.333 grade points.
    func gradePointsFromNumericGrade(_ numericGrade: Double) -> Double {
        if numericGrade >= 97 {
            return 4.333
        } else if numericGrade >= 93 {
            return 4.0
        } else if numericGrade >= 90 {
            return 3.667
        } else if numericGrade >= 87 {
            return 3.333
        } else if numericGrade >= 83 {
            return 3.0
        } else if numericGrade >= 80 {
            return 2.67
        } else if numericGrade >= 77 {
            return 2.333
        } else if numericGrade >= 73 {
            return 2.0
        } else if numericGrade >= 70 {
            return 1.667
        } else if numericGrade >= 67 {
            return 1.333
        } else if numericGrade >= 63 {
            return 1.0
        } else if numericGrade >= 60 {
            return 0.667
        } else {
            return 0.0
        }
    }
}

/// The preview Xcode used to show you the ContentView.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Just showing normal ContentView.
    }
}

/// The view the user will use to add a course.
struct AddCourseView: View {
    
    // Variables associated with the view.
    
    /// View model that handles the user's semester classes and adding them.
    @EnvironmentObject var coursesState: CoursesViewModel
    
    /// The current course the user is adding.
    @State private var course: Course = Course(name: "", creditHours: 3, grade: 0.0)
    /// The string associated with the text field for the course's credit hours.
    @State private var courseCreditHoursString: String = ""
    /// The string associated with the text field for the course's grade.
    @State private var courseGradeString: String = ""
    
    // The actual UI code for the view.
    var body: some View {
        // ScrollView can be better than VStack in a number of cases.
        // ScrollView will still stack items vertically similar to VStack.
        // VStack suffers from some issues associated with TextFields that ScrollView doesn't.
        ScrollView {
            // Add a button to cancel adding a course.
            HStack {
                Button(action: {
                    // Dismiss the sheet the user is viewing to add a course.
                    self.coursesState.showAddCourseSheet = false
                }, label: {
                    Text("Cancel")
                })
                .tint(.red)
                .padding(.horizontal)
                .padding(.bottom)
                
                Spacer() // Push this button all the way to the left.
            }
            
            Text("Add A Course")
                .font(.title)
                .fontWeight(.bold)
                .underline(color: .red)
            
            HStack {
                Text("Name:")
                
                TextField("Course Name", text: self.$course.name) // Edit the course object directly.
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.vertical, 20)
            
            HStack {
                Text("Credit Hours:")
                
                // TODO: Limit entry to numbers only.
                TextField(
                    "0",
                    text: self.$courseCreditHoursString // Edit temporary string.
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad) // Only show numbers for the user to input.
            }
            .padding(.vertical, 20)
            
            HStack {
                Text("Grade:")
                
                // TODO: Limit entry to decimals only.
                TextField(
                    "0.0",
                    text: self.$courseGradeString // Edit temporary string.
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad) // Only show numbers for the user to input.
            }
            .padding(.top, 20)
            
            Text("Enter your grade 0-100.")
                .italic()
                .font(.callout)
                .foregroundColor(.secondary)
            
            Button(action: {
                // TODO: These should be guard statements, not coalesce statements.
                self.course.creditHours = Int(self.courseCreditHoursString) ?? 0
                self.course.grade = Double(self.courseGradeString) ?? 0.0
                self.coursesState.courses.append(self.course)
                // Add the course to the view model.
                self.coursesState.showAddCourseSheet = false
            }, label: {
                Text("Add Course")
                    .fontWeight(.semibold)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.vertical, 20)
            
            Spacer()
        }
        .padding()
    }
}

/// The view that will show the user their calculated GPA.
struct CalculatedGpaView: View {
    
    // Variables associated with the view.
    // TODO: Convert these to StateObject.
    
    /// Whether the sheet the user is currently seeing should be visible.
    /// State variable bound to the parent view allowing it to update the parent view when changed.
    @Binding var showCalculatedGpaSheet: Bool
    /// The user's calculated GPA.
    /// State variable bound to the parent view allowing it to update the parent view when changed.
    @Binding var gpa: Double
    
    // The actual UI code for the view.
    var body: some View {
        VStack {
            HStack {
                Spacer() // Push the button all the way to the right.
                
                Button(action: {
                    // Dismiss the current sheet the user is viewing.
                    self.showCalculatedGpaSheet = false
                }, label: {
                    Text("Done")
                })
                .tint(.red)
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            Text("Calculated GPA")
                .font(.title)
                .fontWeight(.bold)
                .underline(color: .red)
            
            // Format the decimal and display it.
            Text("\(String(format: "%.3f", self.gpa))")
                .font(.title)
                .fontWeight(.heavy)
                .padding(.top, 30)
            // TODO: Animate the initial display of the GPA a little bit.
            
            Text("This will be your grade at the end of the semester given the provided semester classes and grades.")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.top, 30)
                .padding(.horizontal)
                .multilineTextAlignment(.center) // Center text.
            
            Spacer() // Push everything up
        }
        .padding()
    }
}
