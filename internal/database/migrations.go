package database

func (db *DB) createTables() error {
	schema := `
	CREATE TABLE IF NOT EXISTS tasks (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		note TEXT NOT NULL
	);

	CREATE TABLE IF NOT EXISTS amp_threads (
		thread_id TEXT PRIMARY KEY,
		summary TEXT NOT NULL,
		resolved BOOLEAN NOT NULL DEFAULT FALSE
	);

	CREATE TABLE IF NOT EXISTS artifacts (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		filename TEXT NOT NULL,
		content TEXT NOT NULL,
		summary TEXT,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS prompts (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		content TEXT NOT NULL,
		description TEXT,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
		updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS tags (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		label TEXT UNIQUE NOT NULL
	);

	CREATE TABLE IF NOT EXISTS task_tags (
		task_id INTEGER,
		tag_id INTEGER,
		FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
		FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
		PRIMARY KEY (task_id, tag_id)
	);

	CREATE TABLE IF NOT EXISTS thread_tags (
		thread_id TEXT,
		tag_id INTEGER,
		FOREIGN KEY (thread_id) REFERENCES amp_threads(thread_id) ON DELETE CASCADE,
		FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
		PRIMARY KEY (thread_id, tag_id)
	);

	CREATE TABLE IF NOT EXISTS artifact_tags (
		artifact_id INTEGER,
		tag_id INTEGER,
		FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
		FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
		PRIMARY KEY (artifact_id, tag_id)
	);

	CREATE TABLE IF NOT EXISTS prompt_tags (
		prompt_id INTEGER,
		tag_id INTEGER,
		FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE,
		FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
		PRIMARY KEY (prompt_id, tag_id)
	);

	CREATE TABLE IF NOT EXISTS artifact_task_links (
		artifact_id INTEGER,
		task_id INTEGER,
		FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
		FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
		PRIMARY KEY (artifact_id, task_id)
	);

	CREATE TABLE IF NOT EXISTS artifact_thread_links (
		artifact_id INTEGER,
		thread_id TEXT,
		FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
		FOREIGN KEY (thread_id) REFERENCES amp_threads(thread_id) ON DELETE CASCADE,
		PRIMARY KEY (artifact_id, thread_id)
	);

	CREATE TABLE IF NOT EXISTS prompt_task_links (
		prompt_id INTEGER,
		task_id INTEGER,
		FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE,
		FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
		PRIMARY KEY (prompt_id, task_id)
	);

	CREATE TABLE IF NOT EXISTS prompt_thread_links (
		prompt_id INTEGER,
		thread_id TEXT,
		FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE,
		FOREIGN KEY (thread_id) REFERENCES amp_threads(thread_id) ON DELETE CASCADE,
		PRIMARY KEY (prompt_id, thread_id)
	);

	CREATE TABLE IF NOT EXISTS prompt_artifact_links (
		prompt_id INTEGER,
		artifact_id INTEGER,
		FOREIGN KEY (prompt_id) REFERENCES prompts(id) ON DELETE CASCADE,
		FOREIGN KEY (artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
		PRIMARY KEY (prompt_id, artifact_id)
	);

	CREATE INDEX IF NOT EXISTS idx_tasks_id ON tasks(id);
	CREATE INDEX IF NOT EXISTS idx_threads_id ON amp_threads(thread_id);
	CREATE INDEX IF NOT EXISTS idx_artifacts_id ON artifacts(id);
	CREATE INDEX IF NOT EXISTS idx_prompts_id ON prompts(id);
	CREATE INDEX IF NOT EXISTS idx_tags_label ON tags(label);
	`

	_, err := db.conn.Exec(schema)
	return err
}