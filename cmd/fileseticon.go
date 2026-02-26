package cmd

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

// fileseticonCmd represents the fileseticon command
var fileseticonCmd = &cobra.Command{
	Use:   "seticon <extension> <icon> <color>",
	Short: "Customise the file icon and color shown in the 'pricetag file ls' command",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {
		ext := strings.TrimPrefix(args[0], ".")
		icon := args[1]
		color := strings.ToLower(args[2])

		db, path, err := internal.LoadDB()
		if err != nil {
			return err
		}

		db.Icons[ext] = internal.FiletypeIcon{
			Icon:  icon,
			Color: internal.TagColor(color),
		}

		if err := internal.SaveDB(db, path); err != nil {
			return err
		}

		fmt.Printf("Set icon for .%s -> %s (%s)\n", ext, icon, color)
		return nil
	},
	ValidArgsFunction: completeTags,
}

func init() {
	fileCmd.AddCommand(fileseticonCmd)
}
