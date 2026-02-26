package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// newCmd represents the new command
var newCmd = &cobra.Command{
	Use:   "new <name> <color>",
	Short: "Create a new tag",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		name := args[0]
		color := internal.TagColor(args[1])

		if !color.IsValid() {
			return fmt.Errorf("Invalid color: %s", color)
		}

		db, path, err := internal.LoadDB()
		if err != nil {
			return err
		}

		if err := db.CreateTag(name, color); err != nil {
			return err
		}

		return internal.SaveDB(db, path)
	},
	ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
		if len(args) == 1 {
			return internal.ValidColors, cobra.ShellCompDirectiveNoFileComp
		}
		return nil, cobra.ShellCompDirectiveDefault
	},
}

func init() {
	tagCmd.AddCommand(newCmd)
}
