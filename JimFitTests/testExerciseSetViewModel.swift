//
//  testExerciseSetViewModel.swift
//  JimFitTests
//
//  Created by 정준영 on 2023/11/03.
//

import XCTest
@testable import JimFit


final class testExerciseSetViewModel: XCTestCase {
    
    func testIsExerciseSetFinished() {
            let viewModel = ExerciseSetViewModelTest()
            let result = viewModel.isExerciseSetFinished(at: 0)
            
            XCTAssertTrue(result == false)
            XCTAssertTrue(viewModel.isExerciseSetFinishedCalled)
        }
        
        func testExerciseSet() {
            let viewModel = ExerciseSetViewModelTest()
            let exerciseSet = viewModel.exerciseSet(at: 0)
            
            XCTAssertTrue(viewModel.exerciseSetCalled)
            XCTAssertTrue(exerciseSet.repetitionCount == 0)
            XCTAssertTrue(exerciseSet.weight == 0)
        }
        
        func testToggleExerciseSetFinished() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.toggleExerciseSetFinished(at: 0)
            
            XCTAssertTrue(viewModel.toggleExerciseSetFinishedCalled)
        }
        
        func testMoveExerciseSet() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.moveExerciseSet(from: 0, to: 1)
            
            XCTAssertTrue(viewModel.moveExerciseSetCalled)
        }
        
        func testRemoveExerciseSet() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.removeExerciseSet(at: 0)
            
            XCTAssertTrue(viewModel.removeExerciseSetCalled)
        }
        
        func testAppendExerciseSet() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.appendExerciseSet()
            
            XCTAssertTrue(viewModel.appendExerciseSetCalled)
        }
        
        func testStartExerciseTimer() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.startExerciseTimer()
            
            XCTAssertTrue(viewModel.startExerciseTimerCalled)
        }
        
        func testStartRestTimer() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.startRestTimer()
            
            XCTAssertTrue(viewModel.startRestTimerCalled)
        }
        
        func testStopExercise() {
            let viewModel = ExerciseSetViewModelTest()
            
            viewModel.stopExercise()
            
            XCTAssertTrue(viewModel.stopExerciseCalled)
        }

}
