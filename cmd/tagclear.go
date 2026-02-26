package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// tagclearCmd represents the tagclear command
var tagclearCmd = &cobra.Command{
	Use:   "clear <file...>",
	Short: "Remove all tags from file(s)",
	RunE: func(cmd *cobra.Command, args []string) error {
		db, path, err := internal.LoadDB()
		if err != nil {
			return err
		}

		if err := db.ClearFiles(args); err != nil {
			return err
		}

		return internal.SaveDB(db, path)
	},
	ValidArgsFunction: completeFiles,
}

func init() {
	tagCmd.AddCommand(tagclearCmd)
}
