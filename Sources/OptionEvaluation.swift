//
//  OptionEvaluation.swift
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

/// A struct used to describe the evaualted version of a Option.Description
public struct OptionEvaluation: FlagIndexable, CustomStringConvertible {
	
	/// The flag of this evaluation
	public var flag: Option.Flag
	
	/// The parameter of this evaluation.  Nil if flag does not require parameter IE '-v'
	public var parameter: String?
	
	/// CustomStringConvertible
	public var description: String {
		if let p = parameter {
			return "\(flag.description)=\(p)"
		} else {
			return "\(flag.description)"
		}
	}
	
	/// OptionEvaluation Init parses a string read from arguments and attempts
	/// to create a flag and option parameter.  IE '--filePath=/Path' will evaulate
	/// to flag = .long("filePath") and parameter = "/Path"
	///
	/// - Parameter string: The string to parse
	public init?(string: String) {
		switch (string.first?.asString, string.second?.asString) {
			
		// Parsed string is long flag
		case (.some("-"), .some("-")):
			
			let split = string.dropFirst(2).asString.components(separatedBy: "=")
			
			guard
				let longName = split.first,
				longName != "",
				split.second != ""
				else { return nil }
			
			self.flag = .long(longName)
			self.parameter = split.second
			
		// Parsed string is short flag
		case (.some("-"), _):
			
			let split = string.dropFirst().asString.components(separatedBy: "=")
			
			guard
				let shortName = split.first,
				shortName != "",
				split.second != ""
				else { return nil }
			
			self.flag = .short(shortName)
			self.parameter = split.second
		default:
			return nil
		}
	}
}
