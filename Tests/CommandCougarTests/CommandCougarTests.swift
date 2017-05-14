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
			print(evaluation.describer.helpText)
		} catch {
			print(error)
		}
		
	}
	
	func testCommand() {
		
	
		
		var passCallback = false
		
		func callback(command: Command.Evaluation) throws {
			passCallback = true
		}
		
		let args = "swift package -v update --repin".components(separatedBy: " ")
	
		do {
			
			var swift = Command.swift
			let evaulation = try swift.evaluate(arguments: args)
			
			XCTAssert(evaulation["package"]?.name == "package")
			XCTAssert(evaulation["package"]?.options["v"] != nil)
			XCTAssert(evaulation["package edit"] == nil)
			XCTAssert(evaulation["package"]?.subEvaluation?.name == "update")
			XCTAssert(evaulation["package update"]?.options["repin"] != nil)
			
		} catch {
			XCTAssertTrue(false, "\(error)")
		}
		
		
	}
	
	
//	func testCommandCougar() {
//		
//		
//		struct SwiftPackageUpdate: CommandProtocol {
//			var name: String = "swift"
//			var subCommands: [String] = ["package", "update"]
//			var availableOptions: [CommandCougar.Option] = [
//				CommandCougar.Option(short: "v", long: nil, description: "Be more verbose")
//			]
//			var parameters: [CommandCougar.Parameter] = []
//			var description: String = "Update package"
//			
//			func execute(options: [CommandCougar.Flag], parameters: [String]) {
//				print("excecuting with options: \(options) and parameters \(parameters)")
//			}
//		}
//		
//		struct RenameCommand: CommandProtocol {
//			
//			var name: String = "rename"
//			var subCommands: [String] = []
//			var availableOptions: [CommandCougar.Option] = [
//				CommandCougar.Option.init(
//					short: nil,
//					long: "type",
//					parameter: "[tvnamer, filebot]",
//					description: "Renamer type. Default filebot.")
//			]
//			var parameters = [
//				CommandCougar.Parameter.required("directory"),
//				CommandCougar.Parameter.optional("optional-parameter")
//			]
//			var description = "Rename video files in the given directory."
//			
//			func execute(options: [CommandCougar.Flag], parameters: [String]) {
//				
//				print("excecuting with options: \(options) and parameters \(parameters)")
//			}
//		}
//		
//		let cougar = CommandCougar(
//			overview: "The cougar!",
//			usage: "command [subcommand] [options] [parameters]",
//			availableCommands: [
//				SwiftPackageUpdate(),
//				RenameCommand()
//			])
//		
//		//let args1 = ["swift", "package", "update", "-v"]
//		let args2 = ["rename", "--type", "directory"]
//		
//		do {
//			//try cougar.evaluate(args: args1)
//			try cougar.evaluate(args: args2)
//		} catch {
//			XCTFail("POOOOOP: \(error)")
//		}
//		
//		//
//		//		let possible: [Cougar.Token] = [
//		//			.parameter("swift"),
//		//			.parameter("package"),
//		//			.parameter("update"),
//		//			.short(flag: "v"),
//		//			.short(flag: "l")
//		//		]
//		//
//		//		let s = "swift package -v update"
//		//			.components(separatedBy: " ")
//		//			.map { Cougar.Token(string: $0) }
//		//
//		//		switch s {
//		//		case possible:
//		//			print("found")
//		//		default:
//		//			print("poop")
//		//			XCTAssert(false)
//		//		}
//		
//	}
	
	func testParser() {
		
		
	}
	
//    func testClone() {
//		let origin = "git@gitlab.surfandneptune.com:design/fonts.git"
//		do {
//			if FileManager.default.fileExists(atPath: tmp_path) {
//				try FileManager.default.removeItem(atPath: tmp_path)
//			}
//			
//			try Cmd.Git.clone(from: origin, to: tmp_path, args: [])
//			XCTAssertTrue(true)
//		} catch {
//			print(error)
//			XCTAssert(false)
//		}
//	}
//	
//	func testSwiftBuild() {
//		let origin = "git@gitlab.surfandneptune.com:swift/CommandCougar.git"
//		do {
//			if FileManager.default.fileExists(atPath: tmp_path) {
//				try FileManager.default.removeItem(atPath: tmp_path)
//			}
//			try Cmd.Git.clone(from: origin, to: tmp_path, args: [])
//			try Cmd.Swift.build(path: tmp_path)
//			XCTAssertTrue(true)
//		} catch {
//			print(error)
//			XCTAssert(false)
//		}
//	}

    static var allTests : [(String, (CommandCougarTests) -> () throws -> Void)] {
        return [
        ]
    }
}
