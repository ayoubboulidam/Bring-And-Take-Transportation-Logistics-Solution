from google.oauth2 import service_account
from google.auth.transport.requests import Request

# Path to your service account file
key_path = r'C:\service_account.json'

# Load credentials from the service account file
credentials = service_account.Credentials.from_service_account_file(
    key_path,
    scopes=["https://www.googleapis.com/auth/cloud-platform"]
)

# Refresh the credentials to get the access token
credentials.refresh(Request())

# Get the access token
access_token = credentials.token
print(access_token)

