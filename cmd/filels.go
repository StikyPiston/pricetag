package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

var showAll bool

// filelsCmd represents the filels command
var filelsCmd = &cobra.Command{
	Use:   "ls [directory]",
	Short: "List the contents of a directory, including tags",
	Args:  cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		dir := "."
		if len(args) == 1 {
			dir = args[0]
		}

		db, _, err := internal.LoadDB()
		if err != nil {
			return err
		}

		entries, err := os.ReadDir(dir)
		if err != nil {
			return err
		}

		var dirs []os.DirEntry
		var files []os.DirEntry

		for _, entry := range entries {
			name := entry.Name()

			if !showAll && strings.HasPrefix(name, ".") {
				continue
			}

			if entry.IsDir() {
				dirs = append(dirs, entry)
			} else {
				files = append(files, entry)
			}
		}

		sort.Slice(dirs, func(i, j int) bool {
			return dirs[i].Name() < dirs[j].Name()
		})
		sort.Slice(files, func(i, j int) bool {
			return files[i].Name() < files[j].Name()
		})

		// Directories
		for _, d := range dirs {
			line := fmt.Sprintf(" %s", d.Name())
			fmt.Println(internal.Colorize(line, "blue"))
		}

		// Files
		for _, f := range files {
			name := f.Name()
			fullPath := filepath.Join(dir, name)

			absPath, err := internal.CanonicalPath(fullPath)
			if err != nil {
				continue
			}

			ext := strings.TrimPrefix(filepath.Ext(name), ".")

			icon := ""
			fileColor := "white"

			if fileIcon, ok := db.Icons[ext]; ok {
				icon = fileIcon.Icon
				fileColor = string(fileIcon.Color)
			}

			// Base line, icon & filename
			base := fmt.Sprintf("%s %s", icon, name)
			colorBase := internal.Colorize(base, internal.TagColor(fileColor))

			// Tags
			var tagStrings []string
			if tags, ok := db.Paths[absPath]; ok {
				sort.Strings(tags)

				for _, tag := range tags {
					tagColor, exists := db.Tags[tag]
					// Shouldn't be possible, but just to be safe
					if !exists {
						tagColor = "white"
					}

					tagText := fmt.Sprintf("[%s]", tag)
					tagStrings = append(tagStrings, internal.Colorize(tagText, internal.TagColor(tagColor)))
				}
			}

			if len(tagStrings) > 0 {
				fmt.Println(colorBase + " " + strings.Join(tagStrings, ""))
			} else {
				fmt.Println(colorBase)
			}
		}

		return nil
	},
}

func init() {
	fileCmd.AddCommand(filelsCmd)
	filelsCmd.Flags().BoolVarP(&showAll, "all", "a", false, "Show hidden files")
}
