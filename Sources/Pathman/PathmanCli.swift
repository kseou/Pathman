//
//  PathmanCli.swift
//
//
//  Created by KSeou on 08/03/2024.
//  Edited by kseou on 01/09/2024.
//

import ArgumentParser

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Path you want to add to your PATH Env variable")
    
    @Argument(help: "Directory to add to the PATH")
    var path: String
    
    @Flag(name: .long, help: "Skip sourcing the RC file after modification")
    var skipSource = false
    
    func run() throws {
        try PathmanCli.shared.addToPath(path, sourcing: !skipSource)
    }
}

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Path you want to remove from your PATH Env variable")
    
    @Argument(help: "Directory to remove from the PATH")
    var path: String
    
    @Flag(name: .long, help: "Skip sourcing the RC file after modification")
    var skipSource = false
    
    func run() throws {
        try PathmanCli.shared.removeFromPath(path, sourcing: !skipSource)
    }
}

@main
struct PathmanCli: ParsableCommand {
    static let shared: Pathman = {
            do {
                return try Pathman()
            } catch {
                fatalError("Failed to initialize Pathman: \(error.localizedDescription)")
            }
        }()
    
    static var configuration = CommandConfiguration(
        commandName: "pathman",
        abstract: "Pathman is a little tool that helps you manage your shell RC files with ease, focusing on making your life a tad simpler when it comes to handling the PATH environment variable.",
        version: "Pathman v0.2",
        subcommands: [AddCommand.self, RemoveCommand.self])
}

