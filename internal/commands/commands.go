package commands

import (
	"fmt"
	"os"
	"wf/internal/database"
)

type Commands struct {
	db *database.DB
}

func New(db *database.DB) *Commands {
	return &Commands{db: db}
}

func (c *Commands) ShowHelp() {
	help := `wf - Workflow Manager CLI
Usage:
  ./wf add "task description" [tag1,tag2,tag3...]
  ./wf show <task_id>
  ./wf list-tasks [tag]
  ./wf add-thread <thread_id> "summary" [resolved] [tag1,tag2,tag3...]
  ./wf show-thread <thread_id>
  ./wf list-threads [tag]
  ./wf add-artifact <file_path> [tag1,tag2,tag3...]
  ./wf link-artifact <artifact_id> thread <thread_id>
  ./wf summarize-artifact <artifact_id>
  ./wf dump-artifact <artifact_id>
  ./wf list-artifacts [tag]
  ./wf add-prompt "name" "content" [description] [tag1,tag2,tag3...]
  ./wf show-prompt <prompt_id>
  ./wf list-prompts [tag]
  ./wf update-prompt <prompt_id> --name "new name" --content "new content" --description "new desc"
  ./wf delete-prompt <prompt_id>
  ./wf dump-prompt <prompt_id>
  ./wf link-prompt <prompt_id> task <task_id>
  ./wf tag <type> <id> [tag1,tag2,tag3...]
  ./wf tool-overview
  ./wf init <db_path>

Examples:
  ./wf add "Fix login bug" urgent,frontend
  ./wf show 1
  ./wf list-tasks
  ./wf list-tasks urgent
  ./wf add-thread "abc123" "Login discussion" false bug,discussion
  ./wf show-thread "abc123"
  ./wf list-threads
  ./wf list-threads bug
  ./wf add-artifact "plan.md" documentation,planning
  ./wf link-artifact 1 thread "abc123"
  ./wf summarize-artifact 1
  ./wf dump-artifact 1
  ./wf list-artifacts
  ./wf list-artifacts documentation
  ./wf add-prompt "Code Review" "Please review this code for security issues" "Security review prompt" security,review
  ./wf show-prompt 1
  ./wf list-prompts security
  ./wf update-prompt 1 --content "Please review this code for security and performance"
  ./wf delete-prompt 1
  ./wf dump-prompt 1
  ./wf link-prompt 1 task 5
  ./wf tag task 1 urgent,priority
  ./wf tag thread "abc123" resolved
  ./wf tag artifact 1 outdated
  ./wf tag prompt 1 favorite,security
  ./wf tool-overview
  ./wf init ~/my-wf.db`

	fmt.Println(help)
}

func (c *Commands) ToolOverview() {
	fmt.Println("WF Workflow Manager - Go Implementation")
	fmt.Println("Version: 1.0.0")
	fmt.Println("Database:", "Connected")
}

func (c *Commands) ExecuteCommand(command string, args []string) {
	switch command {
	case "tool-overview":
		c.ToolOverview()
	case "init":
		if len(args) > 0 {
			fmt.Printf("Database initialized at: %s\n", args[0])
		} else {
			fmt.Println("Database initialized")
		}
	default:
		fmt.Fprintf(os.Stderr, "Command not yet implemented: %s\n", command)
		c.ShowHelp()
		os.Exit(1)
	}
}