# Get version from MonkWorld
VERSION := $(shell perl -Ilib -MMonkWorld -E 'say $$MonkWorld::VERSION')

RELEASE_BRANCH := release

.PHONY: release

# Create a new release
release:
	@echo "Preparing release v$(VERSION)"
	@# Ensure we're on master
	@if [ "$$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then \
		echo "Error: Must be on master branch to release"; \
		exit 1; \
	fi
	@# Check for uncommitted changes
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Error: Working directory is not clean"; \
		git status; \
		exit 1; \
	fi
	@# Check if release branch exists
	@if ! git show-ref --verify --quiet refs/heads/$(RELEASE_BRANCH); then \
		echo "Creating new $(RELEASE_BRANCH) branch..."; \
		git checkout -b $(RELEASE_BRANCH); \
	else \
		echo "Updating $(RELEASE_BRANCH) branch..."; \
		git checkout $(RELEASE_BRANCH); \
		git merge --ff-only master; \
	fi
	@# Create and push tag
	@echo "Creating tag v$(VERSION)..."
	git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@echo "Pushing to origin..."
	git push origin $(RELEASE_BRANCH)
	git push --tags
	@echo "Switching back to master branch..."
	git checkout master
	@echo "Release v$(VERSION) completed!"
