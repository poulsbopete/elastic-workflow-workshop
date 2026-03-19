.PHONY: setup install prepare-data load-data run dev clean verify help test lint format docker-build docker-run sample-data presentation-html \
	instruqt-validate instruqt-push-serverless publish

help:
	@echo "Review Campaign Detection Workshop - Available Commands"
	@echo "====================================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  setup          - Create venv and install dependencies"
	@echo "  install        - Install dependencies only"
	@echo ""
	@echo "Data Preparation:"
	@echo "  prepare-data   - Run full data preparation pipeline"
	@echo "  load-data      - Load data to Elasticsearch"
	@echo "  sample-data    - Generate small sample dataset for development"
	@echo "  verify         - Verify environment is ready"
	@echo ""
	@echo "Running the Application:"
	@echo "  run            - Run the web application"
	@echo "  dev            - Run in development mode with reload"
	@echo ""
	@echo "Development:"
	@echo "  test           - Run tests"
	@echo "  lint           - Run linters (flake8, mypy)"
	@echo "  format         - Format code (black, isort)"
	@echo "  clean          - Remove generated files"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-run     - Run in Docker container"
	@echo ""
	@echo "Presentation:"
	@echo "  presentation-html - Build Marp deck to HTML (requires marp-cli)"

# Setup & Installation
setup:
	python -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
	@echo ""
	@echo "Setup complete! Activate the virtual environment with:"
	@echo "  source venv/bin/activate"

install:
	pip install -r requirements.txt

install-dev:
	pip install -r requirements-dev.txt

# Data Preparation
prepare-data:
	./admin/prepare_data.sh

load-data:
	python -m admin.load_data \
		--businesses data/processed/businesses.ndjson \
		--users data/processed/users.ndjson \
		--reviews data/historical/reviews.ndjson

sample-data:
	python -m admin.generate_sample_data \
		--businesses 100 \
		--users 500 \
		--reviews 2000 \
		--output data/sample/

verify:
	python -m admin.verify_environment

# Running the Application
run:
	python -m uvicorn app.main:app --host 0.0.0.0 --port 8000

dev:
	python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Streaming
stream-replay:
	python -m streaming.review_streamer --mode replay

stream-inject:
	python -m streaming.review_streamer --mode inject

stream-mixed:
	python -m streaming.review_streamer --mode mixed

# Development
test:
	pytest tests/ -v --cov=app --cov=admin --cov-report=term-missing

lint:
	flake8 app/ admin/ tests/
	mypy app/ admin/

format:
	black app/ admin/ tests/
	isort app/ admin/ tests/

clean:
	rm -rf data/processed/* data/historical/* data/streaming/*
	rm -rf __pycache__ */__pycache__ */*/__pycache__
	rm -rf .pytest_cache .coverage htmlcov/
	rm -rf *.egg-info dist/ build/

# Docker
docker-build:
	docker build -t review-fraud-workshop .

docker-run:
	docker run -p 8000:8000 --env-file .env review-fraud-workshop

# Marp deck → HTML (npm i -g @marp-team/marp-cli)
presentation-html:
	marp presentation/marp/whats-new-elastic-search-9.3.md \
		-o presentation/marp/whats-new-elastic-search-9.3.html

# Connection test
test-connection:
	python -c "from admin.utils.elasticsearch import test_connection; test_connection()"

# --- Git + Instruqt publish (run after: git add -A && git commit) ---
# Restores full serverless track.yml after push; CLI strips challenges locally.
instruqt-validate:
	cd instruqt/review-bomb-workshop-serverless && instruqt track validate

instruqt-push-serverless:
	cd instruqt/review-bomb-workshop-serverless && instruqt track validate && instruqt track push --force
	rm -rf instruqt/review-bomb-workshop-serverless/01-getting-to-know-your-data \
		instruqt/review-bomb-workshop-serverless/02-workflows \
		instruqt/review-bomb-workshop-serverless/03-agent-builder \
		instruqt/review-bomb-workshop-serverless/04-end-to-end-scenario
	cp instruqt/track-serverless.yml instruqt/review-bomb-workshop-serverless/track.yml
	@echo "Synced track.yml from track-serverless.yml. If checksum changed, copy from instruqt output into track-serverless.yml."

publish: instruqt-validate ## git push origin + Instruqt serverless track (commit first; needs auth)
	git push origin main
	$(MAKE) instruqt-push-serverless
