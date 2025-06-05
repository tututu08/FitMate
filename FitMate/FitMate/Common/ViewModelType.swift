//
//  BaseViewModel.swift
//  FitMate
//
//  Created by 강성훈 on 6/4/25.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
