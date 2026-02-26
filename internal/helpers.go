package internal

import (
	"os"
	"path/filepath"
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

type FiletypeIcon struct {
	Icon  string   `json:"icon"`
	color TagColor `json:"color"`
}

type PricetagDB struct {
	Tags  map[string]TagColor     `json:"tags"`
	Icons map[string]FiletypeIcon `json:"icons"`
	Paths map[string][]string     `json:"paths"`
}

func NewDB() *PricetagDB {
	return &PricetagDB{
		Tags:  make(map[string]TagColor),
		Icons: make(map[string]FiletypeIcon),
		Paths: make(map[string][]string),
	}
}

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
