package config

import (
	"os"
	"path/filepath"
)

const (
	DefaultDBName = "wf.db"
	EnvDBPath     = "WF_DB_PATH"
)

func GetDBPath() string {
	if dbPath := os.Getenv(EnvDBPath); dbPath != "" {
		return dbPath
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return DefaultDBName
	}

	return filepath.Join(homeDir, DefaultDBName)
}