package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// tagremoveCmd represents the tagremove command
var tagremoveCmd = &cobra.Command{
	Use:   "remove <file...> --tags <tag...>",
	Short: "Remove tag(s) from file(s)",
	Args:  cobra.MinimumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		if len(tagNames) == 0 {
			return fmt.Errorf("No tags specified") // TODO: Add nerd font icon
		}

		database, path, err := internal.LoadDB()
		if err != nil {
			return err
		}

		if err := database.RemoveTagsFromFiles(args, tagNames); err != nil {
			return err
		}

		return internal.SaveDB(database, path)
	},
	ValidArgsFunction: completeFiles,
}

func init() {
	tagCmd.AddCommand(tagremoveCmd)
	tagremoveCmd.Flags().StringSliceVar(&tagNames, "tags", nil, "Tags to apply")
	tagremoveCmd.RegisterFlagCompletionFunc("tags", completeTags)
}
