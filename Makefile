.PHONY: format lint check clean help install-hooks

SHELL_SCRIPT := wf

help:
	@echo "Available commands:"
	@echo "  format       - Format shell script with shfmt"
	@echo "  lint         - Lint shell script with shellcheck"
	@echo "  check        - Run both format check and lint"
	@echo "  install-hooks - Install git pre-commit hook"
	@echo "  clean        - Remove any temporary files"

format:
	@echo "Formatting $(SHELL_SCRIPT)..."
	shfmt -w -i 4 -ci $(SHELL_SCRIPT)
	@echo "Formatting complete."

lint:
	@echo "Linting $(SHELL_SCRIPT)..."
	shfmt -d -i 4 -ci $(SHELL_SCRIPT)
	@echo "Linting complete."

check: lint
	@echo "Checking format of $(SHELL_SCRIPT)..."
	shfmt -d -i 4 -ci $(SHELL_SCRIPT)
	@echo "All checks passed."

install-hooks:
	@echo "Installing git pre-commit hook..."
	@echo '#!/bin/bash' > .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo '# Run format first to clean up any formatting' >> .git/hooks/pre-commit
	@echo 'make format' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo '# Then run check to ensure everything passes' >> .git/hooks/pre-commit
	@echo 'if ! make check; then' >> .git/hooks/pre-commit
	@echo '    echo "Format check failed. Please fix formatting issues."' >> .git/hooks/pre-commit
	@echo '    exit 1' >> .git/hooks/pre-commit
	@echo 'fi' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo '# Stage any formatting changes' >> .git/hooks/pre-commit
	@echo 'git add wf' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo 'echo "Pre-commit checks passed!"' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed successfully!"

clean:
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete
	@echo "Clean complete."