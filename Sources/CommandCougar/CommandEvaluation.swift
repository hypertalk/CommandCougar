//
//  CommandEvaluation.swift
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


/// A struct used to describe the result of evaluating a command againts a argument array
public struct CommandEvaluation: CommandIndexable {
	
	/// The command description this evaluation was created from
	public var describer: Command
	
	/// The options that were found in the arguments
	public var options: [OptionEvaluation] = []
	
	// The parameters that were found int he arguments
	public var parameters: [ParameterEvaluation] = []
	
	/// An array of evaluations since you can not store the evaluation directly
	private var _subEvaluation: [CommandEvaluation] = []
	
	/// The subEvaluation that was found after this command when evaulated
	public var subEvaluation: CommandEvaluation? {
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
	
	/// The name of this evaluation is the same as the describers name
	public var name: String {
		return describer.name
	}
	
	/// A list of every option for this evaulation and all sub evaluations
	public var allOptions: [OptionEvaluation] {
		return options + (subEvaluation?.allOptions ?? [])
	}
	
	/// Command evaluation Init
	///
	/// - Parameter describer: The Command.Description used to create this evaluation
	public init(describer: Command) {
		self.describer = describer
	}
	
	/// Perform callaback of the describer for this Evaluation and all subEvaluations
	///
	/// - Throws: The callabacks error
	public func performCallbacks() throws {

		// Do not perform callbacks if help is in any option
		if allOptions.contains(where: { $0.flag == "help" }) {
			return
		}
		
		try describer.callback?(self)
		try subEvaluation?.performCallbacks()
	}
	
	/// Validate checks if this evaluation is valid from the describers restrictions.
	/// Correct number of parameters and valid options are checked
	///
	/// - Throws: Error if evaluation is malformed
	public func validate() throws {
		try options.forEach { (option) in
			
			// Make sure the parsed option is a valid option in the command
			guard let foundOption = describer.options[option]  else {
				throw CommandCougar.Errors.invalidFlag(option.description)
			}
			
			// If option requires a parameter, make sure a parameter was parsed
			if foundOption.requiresParameter, option.parameter == nil {
				throw CommandCougar.Errors.validate("Option \(option.flag.description) requires a parameter.")
			}
			
			// If option does not require parameter, make sure parameter was not parsed
			if !foundOption.requiresParameter, option.parameter != nil {
				throw CommandCougar.Errors.validate("Option \(option.flag.description) does not require a parameter.")
			}
		}
		
		guard
			parameters.count <= describer.maxParameterCount,
			parameters.count >= describer.minParameterCount
			else {
				throw CommandCougar.Errors.invalidParameterCount("\(name)")
		}
	}
	
	/// Returns the parameter at the given index for the Command
	///
	/// - Returns: The first parameter of the Command
	/// - Throws: Throws invalidParameterCount if the Command does not have a first parameter
	public func parameter(at index: Int) throws -> String {
		guard index < parameters.count else {
			throw CommandCougar.Errors.parameterAccessError("Parameter at index \(index) not found.")
		}
		return parameters[index]
	}
	
	/// Returns the parameter at the given index for the Command
	///
	/// - Returns: The first parameter of the Command
	/// - Throws: Throws invalidParameterCount if the Command does not have a first parameter
	@available(*, deprecated, message: "Please use parameter(at) instead")
	public func retrieveParameter(at index: Int) throws -> String {
		guard index < parameters.count else {
			throw CommandCougar.Errors.parameterAccessError("Parameter at index \(index) not found.")
		}
		return parameters[index]
	}
	
	/// Allow access to subEvaluations via subscript
	///
	/// - Parameter subEvaluationName: The subEvaluation we are looking for by name
	public subscript(subEvaluationName: String) -> CommandEvaluation? {
		
		let split = subEvaluationName.components(separatedBy: " ")
		
		switch (split.first, split.second) {
		case (.some(let f), .none):
			return _subEvaluation[f]
		case (.some(let f), .some):
			return _subEvaluation[f]?[split.dropFirst().joined(separator: " ")]
		default:
			return nil
		}
	}
}
