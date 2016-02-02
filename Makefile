stencil:
	@echo "Building Stencil"
	@swift build

test: stencil
	@echo "Running Tests"
	@.build/debug/spectre-build
