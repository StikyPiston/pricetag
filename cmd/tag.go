package cmd

import (
	"github.com/spf13/cobra"
)

// tagCmd represents the tag command
var tagCmd = &cobra.Command{
	Use:   "tag",
	Short: "Manage file tags",
}

func init() {
	rootCmd.AddCommand(tagCmd)
}
