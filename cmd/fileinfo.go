package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// fileinfoCmd represents the fileinfo command
var fileinfoCmd = &cobra.Command{
	Use:   "info <file>",
	Short: "Show tags for a given file",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		filePath := args[0]

		// Resolve absolute path
		absPath, err := internal.CanonicalPath(filePath)
		if err != nil {
			return fmt.Errorf("failed to resolve path: %w", err)
		}

		// Load the DB
		database, _, err := internal.LoadDB()
		if err != nil {
			return err
		}

		// Lookup tags
		tags, ok := database.Paths[absPath]
		if !ok || len(tags) == 0 {
			fmt.Printf("%s has no tags\n", absPath)
			return nil
		}

		fmt.Printf("Tags for %s:\n", absPath)
		for _, tag := range tags {
			color, exists := database.Tags[tag]
			if !exists {
				// fallback to default if tag removed
				color = internal.White
			}
			fmt.Printf("  • %s\n", internal.Colorize(tag, color))
		}

		return nil
	},
	ValidArgsFunction: completeFiles, // optional: autocomplete local files
}

func init() {
	fileCmd.AddCommand(fileinfoCmd)
}
