import Foundation

// Database type
struct PricetagDB: Codable {
    var paths: [String: [String]]
}

let fileManager = FileManager.default
let homeDir     = fileManager.homeDirectoryForCurrentUser
let dbDir       = homeDir.appendingPathComponent(".pricetagdb.json")

// Create files if they do not exist
func ensureFileExists(at url: URL, defaultContents: String = "{\"paths\":{}}") {
    if !FileManager.default.fileExists(atPath: url.path) {
        do {
            try defaultContents
                .data(using: .utf8)?
                .write(to: url, options: .atomic)
        } catch {
            print(" Failed to create \(url.lastPathComponent): \(error)")
        }
    }
}

ensureFileExists(at: dbDir)

// Load/Save database
func loadDB() throws -> PricetagDB {
    let url = dbDir
    guard FileManager.default.fileExists(atPath: url.path) else {
        return PricetagDB(paths: [:])
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(PricetagDB.self, from: data)
}

func saveDB(_ db: PricetagDB) throws {
    let data = try JSONEncoder().encode(db)
    try data.write(to: dbDir, options: .atomic)
}

// Tag a file
func tagFile(file: String, tag: String) throws {
    var db = try loadDB()
    if db.paths[file] != nil {
        db.paths[file]!.append(tag)
    } else {
        db.paths[file] = [tag]        
    }
    try saveDB(db)
}

// Remove tag from file
func untagFile(from file: String, tag: String) throws {
    var db = try loadDB()
    guard var tags = db.paths[file] else {
        print("No tags for file \(file)")
        return
    }

    // Remove the tag
    tags.removeAll { $0 == tag }

    if tags.isEmpty {
        // Remove the file entry if no tags left
        db.paths.removeValue(forKey: file)
    } else {
        db.paths[file] = tags
    }
}

// Clear file tags
func clearFile(file: String) throws {
    var db = try loadDB()
    db.paths[file] = []
    try saveDB(db)
}

// Help text
let helptext = """
Usage: pricetag <action> <arguments>
> tag <file> <tag>   - Add the given tag to the given file
> untag <file> <tag> - Removes the given tag from the given file
> clear <file>       - Clears all tags from the given file
"""

// CLI Entrypoint
let args = CommandLine.arguments

if args.count > 1 {
    let action = args[1]

    switch action {
        case "tag":
            try tagFile(file: args[2], tag: args[3])
        case "untag":
            try untagFile(from: args[2], tag: args[3])
        case "clear":
            try clearFile(file: args[2])
        default:
            print(helptext)
    }
} else {
    print(helptext)
}
