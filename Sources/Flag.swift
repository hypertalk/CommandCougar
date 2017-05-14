//
//  Flag.swift
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

public extension Option {

	/// A flag is used to represent a entry in a command line argument
	///
	/// - short: A short entry would be -v.  However flag only needs the v and not the dash
	/// - long: A long entry would be --verbose
	/// - both: Both flags are allowed
	public enum Flag: Equatable, CustomStringConvertible {
		case short(String)
		case long(String)
		case both(short: String, long: String)

		/// The shortname of this Flag
		public var shortName: String? {
			switch self {
			case .short(let s):
				return s
			case .both(let s, _):
				return s
			default:
				return nil
			}
		}

		/// The longname of this flag
		public var longName: String? {
			switch self {
			case .long(let l):
				return l
			case .both(_ , let l):
				return l
			default:
				return nil
			}
		}

		/// The description of this flag as viewed in the help menu
		public var description: String {
			switch self {
			case .short(name: let s):
				return "-\(s)"
			case .long(name: let l):
				return "--\(l)"
			case .both(short: let s, long: let l):
				return "-\(s), --\(l)"
			}
		}

		/// Equatability
		public static func ==(lhs: Flag, rhs: Flag) -> Bool {
			return (lhs.shortName == rhs.shortName) || (lhs.longName == rhs.longName)
		}

		public static func ==(lhs: Flag, rhs: String) -> Bool {
			return (lhs.shortName == rhs) || (lhs.longName == rhs)
		}
	}
}
