#!/bin/bash

# CircleCI API endpoint and job details
CIRCLECI_API="https://circleci.com/api/v2"
VCS="github"
USERNAME="your-username"
PROJECT="your-project"
JOB_ID="your-job-id"

# CircleCI API token
API_TOKEN="your-circleci-api-token"

# Time threshold in minutes
TIME_THRESHOLD=30

# Get job information
job_info=$(curl -sS -X GET "${CIRCLECI_API}/project/${VCS}/${USERNAME}/${PROJECT}/job/${JOB_ID}" \
  -H "Circle-Token: ${API_TOKEN}")

# Extract job status and duration
status=$(echo "$job_info" | jq -r '.status')
duration=$(echo "$job_info" | jq -r '.duration')

# Check if the job is "On Hold" and duration exceeds threshold
if [[ $status == "on_hold" && $duration -gt $(($TIME_THRESHOLD * 60)) ]]; then
  echo "Cancelling job ${JOB_ID}..."
  
  # Cancel the job
  curl -sS -X POST "${CIRCLECI_API}/project/${VCS}/${USERNAME}/${PROJECT}/job/${JOB_ID}/cancel" \
    -H "Circle-Token: ${API_TOKEN}"
  
  echo "Job cancelled!"
else
  echo "Job does not meet cancellation criteria."
fi


# Make sure to replace the placeholders your-username, your-project, your-job-id, and your-circleci-api-token with your actual CircleCI details and API token
# Adjust the TIME_THRESHOLD variable to specify the desired time threshold in minutes.



## Note: This example uses the CircleCI API v2. If you're using a different version of the API, you may need to adjust the endpoints and payload accordingly.
