//
//  Option.swift
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


/// A struct for describing a option that a command is allowed to take in
public struct Option: FlagIndexable, CustomStringConvertible, Equatable {
	
	/// A static help description attached to each command
	public static let help = Option(
		flag: .both(short: "h", long: "help"),
		overview: "The help menu",
		parameterName: nil)
	
	/// The flag for this option
	public var flag: Flag
	
	/// The overview of this option used in the help menu
	public var overview: String
	
	/// The parameter name of this option.  If nil the option takes no parameter IE '-v'
	public var parameterName: String? = nil
	
	/// True if this option requires a parameter
	public var requiresParameter: Bool {
		return parameterName != nil
	}
	
	/// The description of this Option.Description for CustomStringConvertible
	public var description: String {
		return "(\(flag.description)) \(overview) \(parameterName ?? "")"
	}
	
	/// The formatted help text for this Option.Description used in the help menu
	public var helpText: String {
		if let p = parameterName {
			return "\(flag.description)=\(p)"
				.padding(toLength: 20, withPad: " ", startingAt: 0) + overview
		}
		return "\(flag.description)".padding(toLength: 30, withPad: " ", startingAt: 0) + overview
		
	}
	
	/// Option Init
	///
	/// - Parameters:
	///   - flag: The flag for this option
	///   - overview: The overview of this option used in the help menu
	///   - parameterName: The parameter name of this option.  If nil the option takes no parameter IE '-v'
	public init(flag: Flag, overview: String, parameterName: String? = nil) {
		self.flag = flag
		self.overview = overview
		self.parameterName = parameterName
	}
	
	/// Option.Descriptions are equal if they have the same flag
	public static func ==(lhs: Option, rhs: Option) -> Bool {
		return (lhs.flag == rhs.flag)
	}
}
