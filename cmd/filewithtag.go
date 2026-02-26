package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// filewithtagCmd represents the filewithtag command
var filewithtagCmd = &cobra.Command{
	Use:   "withtag <tag...>",
	Short: "List all files with the specified tag(s)",
	Args:  cobra.MinimumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		db, _, err := internal.LoadDB()
		if err != nil {
			return err
		}

		files, err := db.FilesWithTag(args)
		if err != nil {
			return err
		}

		if len(files) == 0 {
			fmt.Println("No files found with the specified tag(s)") // TODO: Add nerd font icon
			return nil
		}

		for _, file := range files {
			color := db.Tags[file]
			fmt.Printf("  • %s\n", internal.Colorize(file, color))
		}

		return nil
	},
	ValidArgsFunction: completeTags,
}

func init() {
	fileCmd.AddCommand(filewithtagCmd)
}
