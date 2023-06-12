import datetime
import requests

circleci_token = "CIRCLE_API_TOKEN"
workflow_id = "PROJECT_ID"
job_number = "YOUR_JOB_NUMBER"
threshold_minutes = 10  # Define the time threshold in minutes

# Get the current time
current_time = datetime.datetime.now()

# Calculate the time threshold
threshold_time = current_time - datetime.timedelta(minutes=threshold_minutes)

# CircleCI API endpoint for retrieving job details
api_url = f"https://circleci.com/api/v2/workflow/{workflow_id}/job/{job_number}"
headers = {"Circle-Token": circleci_token}

# Retrieve the job details
response = requests.get(api_url, headers=headers)
job_details = response.json()

# Get the job status and approval time
job_status = job_details["status"]
approved_at = job_details["approved_at"]

if job_status == "on_hold" and approved_at is not None:
    approved_time = datetime.datetime.strptime(approved_at, "%Y-%m-%dT%H:%M:%S.%fZ")
    if approved_time < threshold_time:
        # Job hasn't been approved within the threshold time, cancel the workflow
        cancel_url = f"https://circleci.com/api/v2/workflow/{workflow_id}/cancel"
        response = requests.post(cancel_url, headers=headers)
        if response.status_code == 200:
            print("Workflow cancelled successfully.")
        else:
            print("Failed to cancel the workflow.")
else:
    print("Job is not on hold or has already been approved.")
