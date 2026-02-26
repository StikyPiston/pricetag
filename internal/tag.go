package internal

import (
	"fmt"
)

func (db *PricetagDB) CreateTag(name string, color TagColor) error {
	if name == "" {
		return fmt.Errorf("tag name cannot be empty")
	}

	if !color.IsValid() {
		return fmt.Errorf("invalid color: %s", color)
	}

	if _, exists := db.Tags[name]; exists {
		return fmt.Errorf("tag '%s' already exists", name)
	}

	db.Tags[name] = color
	return nil
}

func (db *PricetagDB) AddTagsToFiles(files []string, tags []string) error {
	for _, tag := range tags {
		if _, exists := db.Tags[tag]; !exists {
			return fmt.Errorf("tag '%s' does not exist", tag)
		}
	}

	for _, file := range files {
		canon, err := CanonicalPath(file)
		if err != nil {
			return err
		}

		existing := db.Paths[canon]
		tagSet := make(map[string]bool)

		for _, t := range existing {
			tagSet[t] = true
		}

		for _, tag := range tags {
			tagSet[tag] = true
		}

		var final []string
		for t := range tagSet {
			final = append(final, t)
		}

		db.Paths[canon] = final
	}

	return nil
}

func (db *PricetagDB) RemoveTagsFromFiles(files []string, tags []string) error {
	tagSet := make(map[string]bool)
	for _, t := range tags {
		tagSet[t] = true
	}

	for _, file := range files {
		canon, err := CanonicalPath(file)
		if err != nil {
			return err
		}

		existing, ok := db.Paths[canon]
		if !ok {
			continue
		}

		var filtered []string
		for _, t := range existing {
			if !tagSet[t] {
				filtered = append(filtered, t)
			}
		}

		if len(filtered) == 0 {
			delete(db.Paths, canon)
		} else {
			db.Paths[canon] = filtered
		}
	}

	return nil
}

func (db *PricetagDB) ClearFiles(files []string) error {
	for _, file := range files {
		canon, err := CanonicalPath(file)
		if err != nil {
			return err
		}
		delete(db.Paths, canon)
	}
	return nil
}
