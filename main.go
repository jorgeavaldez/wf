package main

import (
	"fmt"
	"os"
	"wf/internal/commands"
	"wf/internal/config"
	"wf/internal/database"
)

func main() {
	if len(os.Args) < 2 {
		showHelp()
		return
	}

	command := os.Args[1]
	args := os.Args[2:]

	if command == "init" {
		initDatabase(args)
		return
	}

	dbPath := config.GetDBPath()
	db, err := database.New(dbPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close()

	cmds := commands.New(db)
	cmds.ExecuteCommand(command, args)
}

func showHelp() {
	cmds := &commands.Commands{}
	cmds.ShowHelp()
}

func initDatabase(args []string) {
	var dbPath string
	if len(args) > 0 {
		dbPath = args[0]
	} else {
		dbPath = config.GetDBPath()
	}

	db, err := database.New(dbPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error initializing database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close()

	fmt.Printf("Database initialized at: %s\n", dbPath)
}