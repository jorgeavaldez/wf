package models

import "time"

type Task struct {
	ID   int      `db:"id"`
	Note string   `db:"note"`
	Tags []string `db:"-"`
}

type Thread struct {
	ThreadID string   `db:"thread_id"`
	Summary  string   `db:"summary"`
	Resolved bool     `db:"resolved"`
	Tags     []string `db:"-"`
}

type Artifact struct {
	ID        int       `db:"id"`
	Filename  string    `db:"filename"`
	Content   string    `db:"content"`
	Summary   *string   `db:"summary"`
	CreatedAt time.Time `db:"created_at"`
	Tags      []string  `db:"-"`
}

type Prompt struct {
	ID          int       `db:"id"`
	Name        string    `db:"name"`
	Content     string    `db:"content"`
	Description *string   `db:"description"`
	CreatedAt   time.Time `db:"created_at"`
	UpdatedAt   time.Time `db:"updated_at"`
	Tags        []string  `db:"-"`
}

type Tag struct {
	ID    int    `db:"id"`
	Label string `db:"label"`
}