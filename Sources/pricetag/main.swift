import Foundation

// Database type
struct PricetagDB: Codable {
    var paths: [String: [String]]
}

let fileManager = FileManager.default
let homeDir     = fileManager.homeDirectoryForCurrentUser
let dbDir       = homeDir.appendingPathComponent(".pricetagdb.json")

// Create files if they do not exist
func ensureFileExists(at url: URL, defaultContents: String = "[]") {
    if FileManager.default.fileExists(atPath: url.path) == false {
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
        return PricetagDB(tags: [], paths: [:])
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
    var db = loadDB()
    db.paths[file].append(tag)
    try saveDB(db: db)
}

// Remove tag from file
func untagFile(from file: String, tag: String) {
    var db = loadDB()
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
func clearFile(file: String) {
    var db = loadDB()
    db.paths[file] = []
    try saveDB(db: db)
}
