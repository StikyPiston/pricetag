package internal

import (
	"encoding/json"
	"github.com/fatih/color"
	"os"
	"path/filepath"
	"strings"
)

const dbFilename = ".pricetagdb.json"

type TagColor string

const (
	Red    TagColor = "red"
	Orange TagColor = "orange"
	Yellow TagColor = "yellow"
	Green  TagColor = "green"
	Blue   TagColor = "blue"
	Purple TagColor = "purple"
	White  TagColor = "white"
	Black  TagColor = "black"
)

// Check if a tag color is valid or not
func (c TagColor) IsValid() bool {
	switch c {
	case Red, Orange, Yellow, Green, Blue, Purple, White, Black:
		return true
	default:
		return false
	}
}

type FiletypeIcon struct {
	Icon  string   `json:"icon"`
	Color TagColor `json:"color"`
}

type PricetagDB struct {
	Tags  map[string]TagColor     `json:"tags"`
	Icons map[string]FiletypeIcon `json:"icons"`
	Paths map[string][]string     `json:"paths"`
}

// Get the canonical path for a given filepath
func CanonicalPath(p string) (string, error) {
	if p == "" {
		return "", nil
	}

	// Expand ~
	if strings.HasPrefix(p, "~") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		p = filepath.Join(home, strings.TrimPrefix(p, "~"))
	}

	// Make absolute
	abs, err := filepath.Abs(p)
	if err != nil {
		return "", err
	}

	// Resolve symlinks (optional but recommended)
	resolved, err := filepath.EvalSymlinks(abs)
	if err == nil {
		abs = resolved
	}

	// Clean path (remove ./, ../, etc.)
	return filepath.Clean(abs), nil
}

// Initialise a new database
func NewDB() *PricetagDB {
	return &PricetagDB{
		Tags:  make(map[string]TagColor),
		Icons: make(map[string]FiletypeIcon),
		Paths: make(map[string][]string),
	}
}

// Check whether or not the database being used is ./.pricetagdb.json or ~/.pricetagdb.json
func ResolveDBPath() (string, error) {
	// Check current directory
	cwd, err := os.Getwd()
	if err != nil {
		return "", err
	}

	localPath := filepath.Join(cwd, dbFilename)

	if _, err := os.Stat(localPath); err == nil {
		// Local DB exists, use it
		return localPath, nil
	}

	// Fallback to home directory
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	return filepath.Join(home, dbFilename), nil
}

// Load the database
func LoadDB() (*PricetagDB, string, error) {
	path, err := ResolveDBPath()
	if err != nil {
		return nil, "", err
	}

	// If DB doesn't exist at resolved path, return empty DB
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return NewDB(), path, nil
	}

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, "", err
	}

	var db PricetagDB
	if err := json.Unmarshal(data, &db); err != nil {
		return nil, "", err
	}

	if db.Tags == nil {
		db.Tags = make(map[string]TagColor)
	}
	if db.Icons == nil {
		db.Icons = make(map[string]FiletypeIcon)
	}
	if db.Paths == nil {
		db.Paths = make(map[string][]string)
	}

	return &db, path, nil
}

// Save the database
func SaveDB(db *PricetagDB, path string) error {
	data, err := json.MarshalIndent(db, "", "   ")
	if err != nil {
		return err
	}

	return os.WriteFile(path, data, 0644)
}

// Print a string in color
func Colorize(text string, c TagColor) string {
	switch c {
	case Red:
		return color.New(color.FgRed).Sprint(text)
	case Orange:
		return color.New(color.FgHiYellow).Sprint(text)
	case Yellow:
		return color.New(color.FgYellow).Sprint(text)
	case Green:
		return color.New(color.FgGreen).Sprint(text)
	case Blue:
		return color.New(color.FgBlue).Sprint(text)
	case Purple:
		return color.New(color.FgMagenta).Sprint(text)
	case Black:
		return color.New(color.FgBlack).Sprint(text)
	case White:
		return color.New(color.FgWhite).Sprint(text)
	default:
		return text
	}
}
