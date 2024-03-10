//
//  Pathman.swift
//
//
//  Created by KSeou on 07/03/2024.
//

import Foundation

enum Shell {
    case bash
    case zsh
    
    var rcFileName: String {
        switch self{
        case .bash:
            return ".bashrc"
        case .zsh:
            return ".zshrc"
        }
    }
    
    static func fromShellPath(_ shellPath: String) -> Shell? {
        switch shellPath {
        case _ where shellPath.hasSuffix("/bash"):
            return .bash
        case _ where shellPath.hasSuffix("/zsh"):
            return .zsh
        default:
            return nil
        }
    }
    
}

struct Pathman {
    private var home: String
    private var shell: Shell
    private let filePath: String
    
    init() {
        self.home = FileManager.default.homeDirectoryForCurrentUser.relativePath
        guard let shellPath = ProcessInfo.processInfo.environment["SHELL"], let shell = Shell.fromShellPath(shellPath) else { fatalError("ERROR: SHELL Environment variable not found!") }
        self.shell = shell
        self.filePath = "\(home)/\(shell.rcFileName)"
    }
}

// MARK: - Private Helper Methods

extension Pathman {
    private func readRcFile(from filePath: String) -> String {
        if let result = try? String(contentsOfFile: filePath) {
            return result
        } else {
            fatalError("Error: Failed to read from file \(filePath).")
        }
    }
    
    private func writeRcFile(content: String) {
        if let result = try? content.write(toFile: filePath, atomically: true, encoding: .utf8) {
            return result
        } else {
            fatalError("Error: Failed to write to file \(shell.rcFileName).")
        }
    }
    
    @discardableResult
    private func runCmd(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/\(self.shell)"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}

// MARK: - Public Methods

extension Pathman {
    func addPath(directory: String) {
        var content = readRcFile(from: filePath)
        let newPathLine = "\nexport PATH=\"\(directory):$PATH\""
        content.append(newPathLine)
        writeRcFile(content: content)
        runCmd("source \(filePath)")
        print("Directory added to PATH in \(shell.rcFileName)")
    }
    
    func removeFromPath(directory: String) {
        var content = readRcFile(from: filePath)
        let pathPrefix = "export PATH=\""
        let pathSuffix = ":$PATH\""
        
        guard let range = content.range(of: pathPrefix),
              let endRange = content.range(of: pathSuffix, options: .backwards),
              let pathRange = content.range(of: directory, options: .literal, range: range.upperBound..<endRange.lowerBound) else {
            print("Error: Failed to remove directory '\(directory)' from PATH in \(shell.rcFileName): Directory not found in PATH")
            return
        }
        
        content.replaceSubrange(pathRange, with: "")
        
        let finalContent = content
            .replacingOccurrences(of: "export PATH=\":$PATH\"", with: "")
            .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        writeRcFile(content: finalContent)
        runCmd("source \(filePath)")
        print("Directory removed from PATH in \(shell.rcFileName)")
    }
}
