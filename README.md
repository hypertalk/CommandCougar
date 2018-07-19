![Command Cougar](https://cloud.githubusercontent.com/assets/4934383/26037640/402d9fd4-38c5-11e7-928a-3cbbb59ef335.png)

An elegant pure Swift library for building command line applications.

[![Build Status](https://travis-ci.org/surfandneptune/CommandCougar.svg?branch=master)](https://travis-ci.org/surfandneptune/CommandCougar)

## Features

- [x] Tons of class, but no classes.  100% organic [pure value types.](https://developer.apple.com/videos/play/wwdc2015/414/)
- [x] Auto generated help menus for main command and sub-commands.
- [x] Help menu format is based on [swift package manager](https://github.com/apple/swift-package-manager)
- [x] Supports multi command callbacks.
- [x] Swift 4 compatibility
- [x] Zero dependency
- [x] Supports Linux and `swift build`

## Requirements

- Mac OS X 10.10+ / Ubuntu 14.10
- Xcode 8
- Swift 4
---

## Usage
  CommandCougar supports a main command as well as subcommands.  This is much like
  the swift package manager interface.  

### `Command`
A command is a `struct` that is used to outline the structure of your command line interface. It can have either a list of subcommands or a list of (`.required` | `.optional`) parameters.


#### Creating a `Command`

``` swift
var helloCommand = Command(
    name: "hello",
    overview: "Say Hello",
    callback: { print($0.options, $0.parameters) },
    options: [
        Option(flag: .short("v"), overview: "Increase verbosity"),
        Option(flag: .short("w"), overview: "Wave hello")
    ],
    parameters:[.optional("Name")])
```

#### Evaluating a `Command`

Once a command has been created, it can be evaluated against a list of
arguments, usually taken from CommandLine.arguments.  The evaluate function
creates and returns a `CommandEvaluation`.

``` swift
let arguments = ["hello", "-v", "Mr.Rogers"]
let helloEvaluation = helloCommand.evaluate(arguments: arguments)
```

Typically, the input of the arguments will be supplied by CommandLine.arguments.  Please note that CommandCougar automatically drops the first argument.

``` swift
let helloEvaluation = helloCommand.evaluate(arguments: CommandLine.arguments)
```

#### Reading a `CommandEvaluation`

A `CommandEvaluation` is a `struct` for representing the results of evaluating a `Command` against a list of arguments.  

``` swift
helloCommand.options        // ['-v', '-w']
helloEvaluation.options     // ['-v']
helloEvaluation.parameters  // ['Mr.Rogers']
```
Notice the evaluation only includes the options which were seen in the arguments list.

#### Performing callbacks

Callbacks pass the `CommandEvaluation` as an input to the function
that was set in the `Command` before evaluation.

``` swift
try helloEvaluation.performCallbacks()
```
---

#### Help menu automatically generated

The help menu is auto generated and the option is added
to the command option set.

``` shell
$ hello --help
OVERVIEW: Say Hello

USAGE: hello [option] <command>

COMMANDS:

OPTIONS:
   -h, --help                    The help menu
   -v                            Increase verbosity
   -w                            Wave hello
```

### `Options`
Options can have either a short flag ie `-v` or a long flag ie `--verbose`.
Options are allowed to have a single optional parameter.  The flag and parameter must be joined with an `=` ie `--path=/tmp`.

``` swift
// will match -v
Option(flag: .short("v"), overview: "verbose")

// will match -v | --verbose
Option(flag: .both(short: "v", long: "verbose"), overview: "verbose")

// will match --path=/etc
Option(flag: .long("path"), overview: "File path", parameterName: "/etc")
```



---
### `Subcommands`

Many command line interfaces like [git](https://github.com/git/git) or the [swift package manager](https://github.com/apple/swift-package-manager) allow for subcommands.  CommandCougar also allows this to be expressed.  A rule to notice is that a command that has subcommands is not allowed to also have parameters.

##### Consider this command:

``` shell
swift package -v update --repin
```

`swift` is the main command.  

`package` is a subcommand of the `swift` command with `-v` as an option.

`update` is a subcommand of the `package` command with `--repin` as an option.


A command to express this list of arguments would be as follows:

``` swift
/// Used for callback
func echo(evaluation: Command.Evaluation) throws {
  print(
    "\(evaluation.name) evaluated with " +
    "options: \(evaluation.options) " +
    "and parameters \(evaluation.parameters)"
    )
}

let swiftCommand =
Command(
    name: "swift",
    overview: "Swift Program",
    callback: echo,
    options: [],
    subCommands: [
        Command(
            name: "package",
            overview: "Perform operations on Swift packages",
            callback: echo,
            options: [
                Option(
                    flag: .both(short: "v", long: "verbose"),
                    overview: "Increase verbosity of informational output"),
                Option(
                    flag: .long("enable-prefetching"),
                    overview: "Increase verbosity of informational output")
            ],
            subCommands: [
                Command(
                    name: "update",
                    overview: "Update package dependencies",
                    callback: echo,
                    options: [
                        Option(
                            flag: .long("repin"),
                            overview: "Update without applying pins and repin the updated versions.")
                    ],
                    subCommands: [])
            ])
    ])
```
### Evaluating `Subcommands`
When evaluating the root command all subcommands will also be evaluated and their callbacks will be fired.

``` swift
do {
    // normally CommandLine.arguments
    let args = ["swift", "package", "-v", "update", "--repin"]
    let evaluation: Command.Evaluation = try swiftCommand.evaluate(arguments: args)
    try evaluation.performCallbacks()
} catch {
    print(error)
}

// Output
// swift evaluated with  options: []  and parameters []
// package evaluated with  options: [-v]  and parameters []
// update evaluated with  options: [--repin]  and parameters []

```

### Accessing the values of the `CommandEvaluation`
To directly access the values of the returned `CommandEvaluation`
``` swift
evaluation["package"]?.name  // results in "package"

evaluation["package"]?.options["v"] // results in Option.Evaluation

evaluation["package"]?.options["v"]?.flag.shortName // results in "v"

evaluation["package"]?.options["enable-prefetching"] // results in nil

evaluation["package"]?["update"]?.options["repin"]?.flag.longName // results in "repin"
```

### Access with throw
To access parameters by index you may use `parameter(at: Int) throws -> String`. If the parameter does
not exist a `parameterAccessError` will be thrown.  

This will turn:
``` swift
func callback(evaluation: CommandEvaluation) throws {
    guard let first = evaluation.parameters.first else {
    throw CommandCougar.Errors.parameterAccessError("Parameter not found.")
	}
}
```

Into:
``` swift
func callback(evaluation: CommandEvaluation) throws {
    let first = try evaluation.parameter(at: 0)
}
```

### Help menu different for subcommands

Help is also generated for subcommands

``` shell
$ swift package --help
OVERVIEW: Perform operations on Swift packages

USAGE: swift package [option] <command>

COMMANDS:
   update                        Update package dependencies

OPTIONS:
   -v, --verbose                 Increase verbosity of informational output
   --enable-prefetching          Enable prefetching in resolver
   -h, --help                    The help menu
```
---

### [EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)

A EBNF of the language supported by CommandCougar is as follows
```
<command> ::= <word> {<option>} ([<command>] | {<parameter>})
<option> ::= <single> | <double>
<single> ::= -<letter>=[<parameter>]
<double> ::= --<word>=[<parameter>]
<parameter> ::= <word>
<word> ::= <letter>+
<letter> ::= a | b | c | d | e...
```

### [CLOC](https://github.com/AlDanial/cloc)

A line count breakdown to show overall size of the project
```
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                           11            133            411            451
-------------------------------------------------------------------------------
SUM:                            11            133            411            451
-------------------------------------------------------------------------------
```
## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, open an issue or submit a pull request.

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

```swift
dependencies: [
    .Package(url: "https://github.com/surfandneptune/CommandCougar.git", majorVersion: 1)
]
```

## License

CommandCougar is released under the MIT license. See LICENSE for details.
