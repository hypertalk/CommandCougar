import XCTest
import Foundation

@testable import CommandCougar

class CommandCougarTests: XCTestCase {

	let swiftCommand =
		Command(
			name: "swift",
			overview: "Swift Program",
			callback: nil,
			options: [],
			subCommands: [
				Command(
					name: "package",
					overview: "Perform operations on Swift packages",
					callback: nil,
					options: [
						Option(
							flag: .both(short: "C", long: "chdir"),
							overview: "Change working directory before any other operation",
							parameterName: "Directory"),
						Option(
							flag: .long("enable-prefetching"),
							overview: "Enable prefetching in resolver"),
						Option(
							flag: .both(short: "v", long: "verbose"),
							overview: "Increase verbosity of informational output")
					],
					subCommands: [
						Command(
							name: "edit",
							overview: "Put a package in editable mode (either --revision or --branch option is required)",
							callback: nil,
							options: [
								Option(
									flag: .long("branch"),
									overview: "The branch to create",
									parameterName: "BRANCH"),
								Option(
									flag: .long("revision"),
									overview: "The revision to edit",
									parameterName: "REVSION")
							],
							parameters: [
								.required("The package to edit")
							]),
						Command(
							name: "update",
							overview: "Update package dependencies",
							callback: nil,
							options: [
								Option(
									flag: .long("repin"),
									overview: "Update without applying pins and repin the updated versions.")
							],
							subCommands: [])
					])
			])
	
	override func setUp() {

		
	}
	
	func testFlagEquatability() {
		
		XCTAssertEqual(Option.Flag.short("v"), Option.Flag.both(short: "v", long: "verbose"))
		XCTAssertEqual(Option.Flag.long("verbose"), Option.Flag.both(short: "v", long: "verbose"))
		XCTAssertEqual(Option.Flag.both(short: "v", long: "verbose"), Option.Flag.both(short: "v", long: "verbose"))
		XCTAssertNotEqual(Option.Flag.both(short: "v", long: "verbose"), Option.Flag.both(short: "v", long: "vvvvv"))

	}

	func testCommandNavigation() {
		
		// Assert subcommands can be accessed with indexing
		XCTAssert(swiftCommand["package"] != nil)
		XCTAssert(swiftCommand["package"]?["edit"] != nil)
		XCTAssert(swiftCommand["package"]?["update"] != nil)

		// Assert options can be accessed with indexing
		XCTAssert(swiftCommand["package"]?.options["C"] != nil)
		XCTAssert(swiftCommand["package"]?.options["chdir"] != nil)
		XCTAssert(swiftCommand["package"]?.options["enable-prefetching"] != nil)
		XCTAssert(swiftCommand["package"]?.options["v"] != nil)
		XCTAssert(swiftCommand["package"]?.options["verbose"] != nil)
		XCTAssert(swiftCommand["package"]?["update"]?.options["repin"] != nil)
		XCTAssert(swiftCommand["package"]?["edit"]?.options["branch"] != nil)
		XCTAssert(swiftCommand["package"]?["edit"]?.options["revision"] != nil)
		
		// Assert parameter info is correct
		XCTAssert(swiftCommand["package"]?.options["chdir"]?.requiresParameter == true)
		XCTAssert(swiftCommand["package"]?.options["verbose"]?.requiresParameter == false)
		XCTAssert(swiftCommand["package"]?["edit"]?.parameters.count == 1)
		XCTAssert(swiftCommand["package"]?["update"]?.parameters.count == 0)

	}
	
	func testCommandModification() {
		
		var newCommand = swiftCommand
		newCommand["package"]?["update"]?.options = []
		newCommand["package"]?["edit"]?.options["branch"]?.parameterName = "newName"
		
		XCTAssert(newCommand["package"]?["update"]?.options.count == 0 )
		XCTAssert(newCommand["package"]?["edit"]?.options["branch"]?.parameterName == "newName")

		
	}
	
	func testCommandValidate() {
		
		// Validate valid commands
		do { try swiftCommand["package"]?.validate() }
		catch { XCTAssert(false, "Error \(error)")  }
		
		do { try swiftCommand["package"]?["edit"]?.validate() }
		catch { XCTAssert(false, "Error \(error)")  }
		
		do { try swiftCommand["package"]?["update"]?.validate() }
		catch { XCTAssert(false, "Error \(error)")  }
		
		// Make sure invalid commands come back as invalid
		
		// Command has both subcommands and parameters
		var invalidCommand1 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [],
				parameters: [
					.required("p")
				])
		invalidCommand1
			.subCommands
			.append(Command(name: "", overview: "", callback: nil, options: [], parameters: []))
		
		// Duplicate subcommand names
		let invalidCommand2 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [],
				subCommands: [
					Command(name: "c", overview: "", callback: nil, options: [], parameters: []),
					Command(name: "c", overview: "", callback: nil, options: [], parameters: [])
				])
		
		// Duplicate flag -v
		let invalidCommand3 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [
					Option(
						flag: .both(short: "v", long: "verbose"),
						overview: "Increase verbosity of informational output"),
					Option(
						flag: .short("v"),
						overview: "Increase verbosity of informational output")
				],
				parameters: [])
		
		// Duplicate flag --verbose
		let invalidCommand4 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [
					Option(
						flag: .both(short: "v", long: "verbose"),
						overview: "Increase verbosity of informational output"),
					Option(
						flag: .long("verbose"),
						overview: "Increase verbosity of informational output")
				],
				parameters: [])
		
		// Duplicate flag -v
		let invalidCommand5 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [
					Option(
						flag: .both(short: "v", long: "verbose"),
						overview: "Increase verbosity of informational output"),
					Option(
						flag: .both(short: "v", long: "vvvvv"),
						overview: "Increase verbosity of informational output")
				],
				parameters: [])
		
		// Duplicate flag --verbose
		let invalidCommand6 =
			Command(
				name: "Command",
				overview: "An invalid command",
				callback: nil,
				options: [
					Option(
						flag: .both(short: "v", long: "verbose"),
						overview: "Increase verbosity of informational output"),
					Option(
						flag: .both(short: "c", long: "verbose"),
						overview: "Increase verbosity of informational output")
				],
				parameters: [])
		
		let invalidCommands = [
			invalidCommand1,
			invalidCommand2,
			invalidCommand3,
			invalidCommand4,
			invalidCommand5,
			invalidCommand6
		]
		
		// Invalid commands should throw and assert true
		for command in invalidCommands {
			do { try command.validate() }
			catch { XCTAssert(true) }
		}
	}

	func testEvaluation() {
		
		do {
			let eval1 = try swiftCommand
				.evaluate(arguments: ["swift", "package", "-v", "update", "--repin"])
			XCTAssert(eval1.options.count == 0)
			XCTAssert(eval1["package"] != nil)
			XCTAssert(eval1["package"]?.options["v"] != nil)
			XCTAssert(eval1["package"]?["edit"] == nil)
			XCTAssert(eval1["package"]?["update"] != nil)
			XCTAssert(eval1["package"]?["update"]?.options["repin"] != nil)
			XCTAssert(eval1["package"]?["update"]?.parameters.count == 0)
			
			let eval2 = try swiftCommand
				.evaluate(arguments: ["swift", "package", "-v", "edit", "--revision=HEAD", "pkg"])
			XCTAssert(eval2.options.count == 0)
			XCTAssert(eval2["package"] != nil)
			XCTAssert(eval2["package"]?.options["v"] != nil)
			XCTAssert(eval2["package"]?["edit"] != nil)
			XCTAssert(eval2["package"]?["update"] == nil)
			XCTAssert(eval2["package"]?["edit"]?.options["revision"] != nil)
			XCTAssert(eval2["package"]?["edit"]?.options["revision"]?.parameter == "HEAD")
			XCTAssert(eval2["package"]?["edit"]?.parameters.count == 1)
			XCTAssert(eval2["package"]?["edit"]?.parameters.first == "pkg")

		} catch {
			XCTAssert(false, "Erorr \(error)")
		}
		
		// Option --revision is missing a parameter. Should throw and assert true.
		do { let _ = try swiftCommand
			.evaluate(arguments: ["swift", "package", "-v", "edit", "--revision", "pkg"]) }
		catch { XCTAssert(true) }
		
		// Option --repin has an unnecessary parameter. Should throw and assert true.
		do { let _ = try swiftCommand
			.evaluate(arguments: ["swift", "package", "-v", "update", "--repin=p"]) }
		catch { XCTAssert(true) }
		
		// Extra parameter for swift package edit. Should throw and assert true.
		do { let _ = try swiftCommand
			.evaluate(arguments: ["swift", "package", "-v", "edit", "--revision=HEAD", "pkg", "extra"]) }
		catch { XCTAssert(true) }
		
		// Missing parameter for swift package edit. Should throw and assert true.
		do { let _ = try swiftCommand
			.evaluate(arguments: ["swift", "package", "-v", "edit", "--revision=HEAD"]) }
		catch { XCTAssert(true) }
		
		
	}
	
    static var allTests : [(String, (CommandCougarTests) -> () throws -> Void)] {
        return [
			("testFlagEquatability", testFlagEquatability),
			("testCommandNavigation", testCommandNavigation),
			("testCommandValidate", testCommandValidate),
			("testEvaluation", testEvaluation)
		]
    }
}
