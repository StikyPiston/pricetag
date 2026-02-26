package cmd

import (
	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// taglistCmd represents the taglist command
var taglistCmd = &cobra.Command{
	Use:   "list",
	Short: "List available tags",
	RunE: func(cmd *cobra.Command, args []string) error {
		db, _, err := internal.LoadDB()
		if err != nil {
			return err
		}

		db.ListTags()
		return nil
	},
}

func init() {
	tagCmd.AddCommand(taglistCmd)
}
