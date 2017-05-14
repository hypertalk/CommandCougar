import XCTest
import Foundation


// Command (SubCommand Option) (SubCommand (Option Parameter))
// swift package -v update --help

// Command SubCommand (SubCommand Option)
// swift package update --repin
//


// Command (SubCommand Option) (SubCommand Parameter (Option Parameter))
// swift package -v  edit Clover --revision HEAD

// Command (SubCommand Option) (SubCommand (Option Parameter) Parameter)
// swift package -v edit --revision HEAD Clover

// Command (SubCommand Option (Option Parameter)) (SubCommand Parameter (Option Parameter))
// swift package -v --build-path ~/ edit Clover --revision HEAD

// Command (SubCommand [Option[Parameter]]) (SubCommand Parameter [Option[Parameter]])
// Command (SubCommand [Option[Parameter]]) (SubCommand [Option[Parameter]] Parameter)

// <command> ::= <word> {<option>} {<command>}
// <command> ::= <finalcommand>
// <finalcommand> ::= <word> (<option> <parameter> | <parameter> <option)
// <option> ::= <single> | <double>
// <single> ::= -<letter> [<parameter>]
// <double> ::= --<word> [<parameter>]
// <parameter> ::= <word>
// <word> ::= <letter>+
// <letter> ::= a | b | c | d | e...

@testable import CommandCougar

class CommandCougarTests: XCTestCase {



	override func setUp() {


	}

	func testIndexing() {
		let swift = Command.swift
		XCTAssert(swift["package"]?.options["v"] != nil)
		XCTAssert(swift["package update"]?.options["repin"] != nil)
		XCTAssert(swift["package edit"]?.maxParameterCount == 1)
	}

	func echo(evaluation: Command.Evaluation) throws {
		print(
			"\(evaluation.name) evaluated with " +
				" options: \(evaluation.options) " +
			" and parameters \(evaluation.parameters)"
		)
	}

	func testMarkdownExample() {
		func echo(evaluation: Command.Evaluation) throws {
			print(
				"\(evaluation.name) evaluated with " +
				"options: \(evaluation.options) " +
				"and parameters \(evaluation.parameters)"
			)
		}

		let swiftCommand =
		Command.Description(
			name: "swift",
			overview: "Swift Program",
			callback: echo,
			options: [],
			subCommands: [
				Command.Description(
					name: "package",
					overview: "Perform operations on Swift packages",
					callback: echo,
					options: [
						Option.Description(
							flag: .both(short: "v", long: "verbose"),
							overview: "Increase verbosity of informational output"),
						Option.Description(
							flag: .long("enable-prefetching"),
							overview: "Enable prefetching in resolver")
					],
					subCommands: [
						Command.Description(
							name: "update",
							overview: "Update package dependencies",
							callback: echo,
							options: [
								Option.Description(
									flag: .long("repin"),
									overview: "Update without applying pins and repin the updated versions.")
							],
							subCommands: [])
					])
			])

		// args normally is CommandLine.arguments
		do {
			let args = ["swift", "package", "-v", "update", "--repin"]
			let evaluation: Command.Evaluation = try swiftCommand.evaluate(arguments: args)
			try evaluation.performCallbacks()
		} catch {
			print(error)
		}

	}


    static var allTests : [(String, (CommandCougarTests) -> () throws -> Void)] {
        return [
        ]
    }
}
