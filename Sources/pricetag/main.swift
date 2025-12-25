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
    var icons: [String: String]
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
          "icons": {},
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
        return PricetagDB(tags: [:], icons: [:], paths: [:])
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

// Tag format helper
func formatTags(_ tags: [String], db: PricetagDB) -> String {
    tags.compactMap { tag in
        guard let color = db.tags[tag] else { return nil }
        return "\(color.ansiCode)[\(tag)]\(TagColor.reset)"
    }.joined(separator: " ")
}

// Icon helper
func iconForItem(named name: String, fullPath: String, db: PricetagDB) -> String {
    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)

    if isDir.boolValue {
        return " "
    }

    let ext = URL(fileURLWithPath: name).pathExtension.lowercased()
    if let icon = db.icons[ext] {
        return icon
    }

    return " "
}

// Item printing helper
func printItem(_ name: String, db: PricetagDB) {
    let fullPath = canonicalPath(name)

    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)

    let rawIcon = iconForItem(named: name, fullPath: fullPath, db: db)

    let icon: String
    let displayName: String

    if isDir.boolValue {
        let blue = TagColor.blue.ansiCode
        let reset = TagColor.reset

        icon = "\(blue)\(rawIcon)\(reset)"
        displayName = "\(blue)\(name)\(reset)"
    } else {
        icon = rawIcon
        displayName = name
    }

    if let tags = db.paths[fullPath], !tags.isEmpty {
        let tagString = formatTags(tags, db: db)
        print("\(icon) \(displayName) \(tagString)")
    } else {
        print("\(icon) \(displayName)")
    }
}

// List working directory contents
func pricetagLS(showAll: Bool) throws {
    let db = try loadDB()
    let cwd = FileManager.default.currentDirectoryPath
    let items = try FileManager.default.contentsOfDirectory(atPath: cwd)

    var directories: [String] = []
    var files: [String] = []

    for name in items {
        if !showAll && name.hasPrefix(".") {
            continue
        }

        let fullPath = canonicalPath(name)

        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)

        if isDir.boolValue {
            directories.append(name)
        } else {
            files.append(name)
        }
    }

    for name in directories.sorted() {
        printItem(name, db: db)
    }

    for name in files.sorted() {
        printItem(name, db: db)
    }
}

// Set icon for file extension
func setIcon(extension ext: String, icon: String) throws {
    var db = try loadDB()
    db.icons[ext.lowercased()] = icon
    try saveDB(db)
}

// Get files with given tag
func filesWithTag(_ tag: String) throws {
    let db = try loadDB()

    // Validate tag exists
    guard db.tags[tag] != nil else {
        print("󱈠 Tag '\(tag)' does not exist")
        return
    }

    let matches = db.paths
        .filter { (_, tags) in tags.contains(tag) }
        .map { $0.key }
        .sorted()

    if matches.isEmpty {
        print("󱈠 No files with tag \(tag)")
        return
    }

    print(" Files with tag \(tag):")
    for path in matches {
        print(path)
    }
}

// Help text
let helptext = """
Usage: pricetag <action> <arguments>
> clear <file>                                           - Clears all tags from the given file
> createtag <name> <red|orange|yellow|green|blue|purple> - Create a new tag with the given name and color
> fileswithtag <tag>                                     - Lists all files with the given tag
> info <file>                                            - Lists tags for the given file
> listtags                                               - Lists available tags
> ls                                                     - Lists the contents of the current directory + icons and tags
> seticon <extension> <icon>                             - Sets icon for given file extension (for pricetag ls command)
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
        case "listtags":
            try listTags()
        case "ls":
            let showAll = args.contains("-a")
            try pricetagLS(showAll: showAll)
        case "seticon":
            try setIcon(extension: args[2], icon: args[3])
        default:
            print(helptext)
    }
} else {
    print(helptext)
}
