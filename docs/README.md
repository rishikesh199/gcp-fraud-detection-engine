# Project Documentation & Portal

## 📌 Enterprise Purpose
Comprehensive documentation is the backbone of any maintainable enterprise system. This directory stores the deep architectural documentation, interactive HTML portals, and static assets (images, system diagrams) that explain the inner workings of the Fraud Detection Engine.

## 📂 Contents
- **Architecture Diagrams:** High-level system designs, VPC network boundaries, and Lambda Architecture workflows.
- **Data Dictionaries:** Detailed definitions of the 26-column master schema and the dbt star schema output.
- **Runbooks:** Step-by-step guides for Disaster Recovery (e.g., how to replay Dead Letter Queue messages).
- **HTML Portal:** The self-hosted, interactive developer portal (`index.html`, `commands.html`, `script-catalog.html`).

## 🛠️ Maintenance Guidelines
Whenever a structural change is made to the Terraform infrastructure, BigQuery schema, or Airflow DAG execution order, the corresponding diagram and runbook in this `/docs` folder **must** be updated simultaneously in the same Pull Request.
