//
//  Command.Evaluation.swift
//  CommandCougar
//
//  Copyright (c) 2017 Surf & Neptune LLC (http://surfandneptune.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
public extension Command {

	/// A struct used to describe the result of evaluating a command againts a argument array
	public struct Evaluation: CommandIndexable {

		/// The command description this evaluation was created from
		public var describer: Description

		/// The options that were found in the arguments
		public var options: [Option.evaluation] = []

		// The parameters that were found int he arguments
		public var parameters: [Parameter.evaluation] = []

		/// An array of evaluations since you can not store the evaluation directly
		private var _subEvaluation: [Evaluation] = []

		/// The subEvaluation that was found after this command when evaulated
		public var subEvaluation: Evaluation? {
			get {
				return _subEvaluation.first
			} set {
				if let n = newValue {
					_subEvaluation = [n]
				} else {
					_subEvaluation = []
				}

			}
		}


		/// Command evaluation Init
		///
		/// - Parameter describer: The Command.Description used to create this evaluation
		public init(describer: Description) {
			self.describer = describer
		}

		/// The name of this evaluation is the same as the describers name
		public var name: String {
			return describer.name
		}


		/// Allow access to subEvaluations via subscript
		///
		/// - Parameter subevaluationName: The subevaluation we are looking for by name
		public subscript(subevaluationName: String) -> Evaluation? {

			let split = subevaluationName.components(separatedBy: " ")

			switch (split.first, split.second) {
			case (.some(let f), .none):
				return _subEvaluation[f]
			case (.some(let f), .some):
				return _subEvaluation[f]?[split.dropFirst().joined(separator: " ")]
			default:
				return nil
			}
		}


		/// Perform callaback of the describer for this Evaluation and all subEvaluations
		///
		/// - Throws: The callabacks error
		public func performCallbacks() throws {
			try describer.callback?(self)
			try subEvaluation?.performCallbacks()
		}


		/// Validate checks if this evaluation is valid from the describers restrictions.
		/// Correct number of parameters and valid options are checked
		///
		/// - Throws: Error if evaluation is malformed
		public func validate() throws {
			options.forEach { (option) in
				guard describer.options.contains(option) else {
					fatalError("poop")
				}
			}

			guard
				parameters.count <= describer.maxParameterCount,
				parameters.count >= describer.minParameterCount
			else {
				fatalError("poop")
			}
		}

	}
}
