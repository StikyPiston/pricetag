import Foundation

// Tag colors
enum TagColor: String, Codable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
}

extension TagColor {
    var ansiCode: String {
        switch self {
        case .red:    return "\u{001B}[31m"
        case .orange: return "\u{001B}[38;5;208m"
        case .yellow: return "\u{001B}[33m"
        case .green:  return "\u{001B}[32m"
        case .blue:   return "\u{001B}[34m"
        case .purple: return "\u{001B}[35m"
        }
    }

    static let reset = "\u{001B}[0m"
}

// Database type
struct PricetagDB: Codable {
    var tags: [String: TagColor]
    var paths: [String: [String]]
}

let fileManager = FileManager.default
let homeDir     = fileManager.homeDirectoryForCurrentUser
let dbDir       = homeDir.appendingPathComponent(".pricetagdb.json")

// Create files if they do not exist
func ensureFileExists(at url: URL) {
    if !FileManager.default.fileExists(atPath: url.path) {
        let defaultJSON = """
        {
          "tags": {},
          "paths": {}
        }
        """
        do {
            try defaultJSON.data(using: .utf8)?.write(to: url, options: .atomic)
        } catch {
            print(" Failed to create database: \(error)")
        }
    }
}

ensureFileExists(at: dbDir)

// Expand paths
func canonicalPath(_ path: String) -> String {
    let url = URL(fileURLWithPath: path, relativeTo: FileManager.default.currentDirectoryPath.hasPrefix("/")
        ? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        : nil)

    let expanded = NSString(string: url.path).expandingTildeInPath
    let standardized = URL(fileURLWithPath: expanded).standardizedFileURL

    return standardized.path
}


// Load/Save database
func loadDB() throws -> PricetagDB {
    let url = dbDir
    guard FileManager.default.fileExists(atPath: url.path) else {
        return PricetagDB(tags: [:], paths: [:])
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(PricetagDB.self, from: data)
}

func saveDB(_ db: PricetagDB) throws {
    let data = try JSONEncoder().encode(db)
    try data.write(to: dbDir, options: .atomic)
}

// Create a tag
func createTag(name: String, colorName: String) throws {
    guard let color = TagColor(rawValue: colorName) else {
        print(" Invalid color '\(colorName)'")
        print("Valid colors: red, orange, yellow, green, blue, purple")
        return
    }

    var db = try loadDB()

    if db.tags[name] != nil {
        print("󱤇 Tag '\(name)' already exists")
        return
    }

    db.tags[name] = color
    try saveDB(db)

    print("󰜢 Created tag '\(name)' (\(color.rawValue))")
}

// Tag a file
func tagFile(file: String, tag: String) throws {
    var db = try loadDB()

    guard db.tags[tag] != nil else {
        print("󰜣 Tag '\(tag)' does not exist")
        return
    }

    let fullPath = canonicalPath(file)

    var tags = db.paths[fullPath, default: []]

    if !tags.contains(tag) {
        tags.append(tag)
    }

    db.paths[fullPath] = tags
    try saveDB(db)
    print(" Added tag \(tag) to file \(file)")
}

// Remove tag from file
func untagFile(from file: String, tag: String) throws {
    let file = canonicalPath(file)

    var db = try loadDB()
    guard var tags = db.paths[file] else {
        print("󱈠 No tags for file \(file)")
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

    try saveDB(db)

    print("󰤐 Removed tag \(tag) from \(file)")
}

// Clear file tags
func clearFile(file: String) throws {
    let file = canonicalPath(file)

    var db = try loadDB()
    db.paths[file] = []
    try saveDB(db)

    print("󱈠 Cleared tags from \(file)")
}

// List available tags
func listTags() throws {
    let db = try loadDB()

    if !db.tags.isEmpty {
        print(" Available tags:")
        for tag in db.tags {
            print(tag)
        }
    } else {
        print("󱈠 No tags available")        
    }
}

// Get tag info for a file
func fileInfo(for file: String) throws {
    let file = canonicalPath(file)

    let db = try loadDB()

    guard let tags = db.paths[file], !tags.isEmpty else {
        print("󱈠 No tags for file \(file)")
        return
    }

    for tag in tags {
        print(" Tags for \(file):")
        if let color = db.tags[tag] {
            print("\(color.ansiCode)\(tag)\(TagColor.reset)")
        } else {
            // Should not happen, but defensive
            print(tag)
        }
    }
}

// Help text
let helptext = """
Usage: pricetag <action> <arguments>
> clear <file>                                           - Clears all tags from the given file
> createtag <name> <red|orange|yellow|green|blue|purple> - Create a new tag with the given name and color
> info <file>                                            - Lists tags for the given file
> tag <file> <tag>                                       - Add the given tag to the given file
> untag <file> <tag>                                     - Removes the given tag from the given file
"""

// CLI Entrypoint
let args = CommandLine.arguments

if args.count > 1 {
    let action = args[1]

    switch action {
        case "createtag":
            try createTag(name: args[2], colorName: args[3])
        case "tag":
            try tagFile(file: args[2], tag: args[3])
        case "untag":
            try untagFile(from: args[2], tag: args[3])
        case "clear":
            try clearFile(file: args[2])
        case "info":
            try fileInfo(for: args[2])
        default:
            print(helptext)
    }
} else {
    print(helptext)
}
