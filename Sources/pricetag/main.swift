import Foundation

// Database type
struct PricetagDB: Codable {
    var tags: [String]
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

func loadDB(from url: URL) throws -> PricetagDB {
    guard FileManager.default.fileExists(atPath: url.path) else {
        return PricetagDB(tags: [], paths: [:])
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(PricetagDB.self, from: data)
}

func saveDB(_ db: PricetagDB, to url: URL) throws {
    let data = try JSONEncoder().encode(db)
    try data.write(to: url, options: .atomic)
}
