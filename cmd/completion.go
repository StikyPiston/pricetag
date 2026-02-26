package cmd

import (
	"github.com/spf13/cobra"
	"github.com/stikypiston/pricetag/internal"
)

func completeTags(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	db, _, err := internal.LoadDB()
	if err != nil {
		return nil, cobra.ShellCompDirectiveDefault
	}

	var tags []string
	for name := range db.Tags {
		tags = append(tags, name)
	}

	return tags, cobra.ShellCompDirectiveNoFileComp
}

func completeFiles(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	return nil, cobra.ShellCompDirectiveDefault
}
