.PHONY: format lint check clean help

SHELL_SCRIPT := wf

help:
	@echo "Available commands:"
	@echo "  format    - Format shell script with shfmt"
	@echo "  lint      - Lint shell script with shellcheck"
	@echo "  check     - Run both format check and lint"
	@echo "  clean     - Remove any temporary files"

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

clean:
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete
	@echo "Clean complete."