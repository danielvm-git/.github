# GitHub Actions Architecture

This document shows the continuous integration and continuous deployment (CI/CD) architecture for the danielvm-git portfolio.

## 1. Portfolio Architecture

The portfolio uses a central template repository. The `.github` repository gives reusable workflows and actions to all consumer repositories.

- **Consumer Repositories**: 28 repositories use the central templates.
- **Workflow Templates**: The `.github/workflow-templates` directory has the starter files.
- **Reusable Workflows**: The `.github/workflows` directory has the shared CI/CD logic.
- **Deploy Action**: The `.github/actions/bigbase-deploy` directory has the deployment steps.

[View Architecture Diagram](./diagrams/portfolio-ci-cd-architecture.html)

## 2. Pipeline Workflow

The pipeline separates the CI stage from the CD stage. This separation makes sure that only safe code goes to production.

1. **Pull Request**: A pull request starts the CI workflow.
2. **Push to Main**: A push to the main branch starts the CI workflow.
3. **Test and Lint**: The CI workflow tests the code. A new commit cancels an active CI job.
4. **Build**: The CI workflow builds the artifact and creates a `deploy-meta.json` file.
5. **Deploy**: The CD workflow reads the `deploy-meta.json` file and sends the artifact to BigBase. The CD workflow does not stop if a new commit arrives.
6. **Smoke Test**: The system does a health check 8 times to verify the deployment.

[View Workflow Diagram](./diagrams/ci-cd-pipeline-workflow.html)

## 3. Artifact Handoff

The CI workflow and the CD workflow use the `deploy-meta.json` file to communicate. This prevents the CD workflow from building the source code again.

1. The CI workflow builds the application bundle.
2. The CI workflow uploads the `deploy-meta.json` file to GitHub Artifacts.
3. The CI workflow starts the `workflow_run` event.
4. The CD workflow downloads the `deploy-meta.json` file.
5. The CD workflow sends a POST request to the BigBase API with the pinned SHA.
6. The BigBase API returns a deploy ID.
7. The CD workflow polls the health check endpoint.

[View Sequence Diagram](./diagrams/artifact-handoff-sequence.html)

## 4. Job Execution Lifecycle

The pipeline has three main parts: Pipeline, Deployment, and Outcomes.

1. **Pipeline**: The system receives a push, runs tests, and builds the code.
2. **Deployment**: The system waits for the trigger, deploys the code, and verifies the deployment.
3. **Outcomes**: The deployment goes to a LIVE state if it passes. The deployment goes to a FAILED state if it fails.

[View Lifecycle Diagram](./diagrams/job-execution-lifecycle.html)
