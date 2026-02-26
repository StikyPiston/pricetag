package cmd

import (
	"github.com/spf13/cobra"
)

// fileCmd represents the file command
var fileCmd = &cobra.Command{
	Use:   "file",
	Short: "Interact with files",
}

func init() {
	rootCmd.AddCommand(fileCmd)
}
