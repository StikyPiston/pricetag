package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

var tagNames []string

// tagaddCmd represents the tagadd command
var tagaddCmd = &cobra.Command{
	Use:   "tag <file...> --tags <tag...>",
	Short: "Add tag(s) to file(s)",
	Args:  cobra.MinimumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		if len(tagNames) == 0 {
			return fmt.Errorf("no tags specified")
		}

		db, path, err := internal.LoadDB()
		if err != nil {
			return err
		}

		if err := db.AddTagsToFiles(args, tagNames); err != nil {
			return err
		}

		return internal.SaveDB(db, path)
	},
}

func init() {
	tagCmd.AddCommand(tagaddCmd)
	tagCmd.Flags().StringSliceVar(&tagNames, "tags", nil, "Tags to apply")
}
