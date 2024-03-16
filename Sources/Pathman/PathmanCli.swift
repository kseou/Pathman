//
//  PathmanCli.swift
//
//
//  Created by KSeou on 08/03/2024.
//

import ArgumentParser

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Path you want to add to your PATH Env variable")
    
    @Argument(help: "Directory to add to the PATH")
    var path: String
    
    @Flag(name: .shortAndLong, help: "Disable automatic sourcing of the RC file after adding PATH")
    var noSource: Bool = false
    
    func run() throws {
        PathmanCli.shared.addPath(directory: path, sourcing: noSource)
    }
}

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Path you want to remove from your PATH Env variable")
    
    @Argument(help: "Directory to remove from the PATH")
    var path: String
    
    @Flag(name: .shortAndLong, help: "Disable automatic sourcing of the RC file after adding PATH")
    var noSource: Bool = false
    
    func run() throws {
        PathmanCli.shared.removeFromPath(directory: path, sourcing: noSource)
    }
}

@main
struct PathmanCli: ParsableCommand {
    static var shared: Pathman = Pathman()
    static var configuration = CommandConfiguration(
        commandName: "pathman",
        abstract: "Pathman is a little tool that helps you manage your shell RC files with ease, focusing on making your life a tad simpler when it comes to handling the PATH environment variable.",
        version: "Pathman v0.2",
        subcommands: [AddCommand.self, RemoveCommand.self])
}

