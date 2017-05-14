//
//  FlagIndexable.swift
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

public enum Errors: Error {
	case callback(String)
	case parse(String)
	case invalidParameterCount(String)
	case invalidFlag(String)
}


/// A somthing flagIndexeable if it contains a flag value.
/// Used by Option.Description and Option.Evaluation
public protocol FlagIndexable {
	var flag: Option.Flag { get }
}

public extension Array where Element: FlagIndexable {

	/// Allows for subscripting of this array by flagName
	///
	/// - Parameter flagName: The flagName
	public subscript (flagName: String) -> Element? {
		return first(where: { $0.flag == flagName })
	}

	/// Check if this array contains a Element equal to the given FlagIndexable
	///
	/// - Parameter element: The FlagIndexable we are looking for
	/// - Returns: True if found
	public func contains(_ element: FlagIndexable) -> Bool {
		return contains(where: { $0.flag == element.flag })
	}
}

///
public protocol CommandIndexable {
	var name: String { get }
}

public extension Array where Element: CommandIndexable {
	public subscript(commandName: String) -> Element? {
		return first(where: { $0.name == commandName })
	}
}
