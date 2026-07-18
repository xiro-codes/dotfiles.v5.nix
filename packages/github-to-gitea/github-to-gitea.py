#!/usr/bin/env python3
"""
GitHub to Gitea Repository Migration Script
----------------------------------------

This script automates the process of migrating (mirroring) all repositories from a GitHub account
to a Gitea instance. It creates mirrored repositories that will stay in sync with the original
GitHub repositories.

Required Environment Variables:
-----------------------------
GITHUB_TOKEN      : Personal access token from GitHub
                    Required scopes: 'repo' (Full control of private repositories)
                    Generate at: https://github.com/settings/tokens

GITEA_TOKEN       : Access token from your Gitea instance
                    Required permissions: Write access to repositories
                    Generate at: your-gitea-instance/user/settings/applications

GITEA_URL         : Base URL of your Gitea instance
                    Example: https://gitea.yourdomain.com

GITHUB_USERNAME   : Your GitHub username
                    Used for authentication when cloning repositories

GITEA_USERNAME    : Your Gitea username
                    Used to determine where to create the mirrored repositories

Usage:
------
1. Set all environment variables:
   export GITHUB_TOKEN="your_github_token"
   export GITEA_TOKEN="your_gitea_token"
   export GITEA_URL="https://gitea.yourdomain.com"
   export GITHUB_USERNAME="your_github_username"
   export GITEA_USERNAME="your_gitea_username"

2. Install required package:
   pip install requests

3. Run the script:
   python github_to_gitea.py

Features:
--------
- Migrates all repositories (public and private)
- Creates mirrored repositories that stay in sync with GitHub
- Preserves repository descriptions and privacy settings
- Handles pagination for accounts with many repositories
- Includes error handling and progress reporting
"""

import requests
import urllib3
import json
import time
from typing import List, Dict
import os
from urllib.parse import urljoin

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class GitHubToGiteaMigrator:
    def __init__(
        self,
        github_token: str,
        gitea_token: str,
        gitea_url: str,
        github_username: str,
        gitea_username: str
    ):
        self.github_token = github_token
        self.gitea_token = gitea_token
        self.gitea_url = gitea_url.rstrip('/')
        self.github_username = github_username
        self.gitea_username = gitea_username
        
        # Headers for API requests
        self.github_headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        self.gitea_headers = {
            'Authorization': f'token {gitea_token}',
            'Content-Type': 'application/json'
        }

    def get_github_repos(self) -> List[Dict]:
        """Fetch all repositories from GitHub"""
        repos = []
        page = 1
        while True:
            response = requests.get(
                f'https://api.github.com/user/repos',
                headers=self.github_headers,
                params={'page': page, 'per_page': 100},
                verify=False
            )
            if response.status_code != 200:
                raise Exception(f"Failed to fetch GitHub repos: {response.text}")
            
            page_repos = response.json()
            if not page_repos:
                break
                
            repos.extend(page_repos)
            page += 1
            
        return repos

    def migrate_repo(self, repo: Dict) -> bool:
        """Migrate a single repository to Gitea"""
        migration_url = urljoin(self.gitea_url, '/api/v1/repos/migrate')
        
        migration_data = {
            "clone_addr": repo['clone_url'],
            "auth_username": self.github_username,
            "auth_token": self.github_token,
            "mirror": True,
            "private": repo['private'],
            "description": repo['description'] or "",
            "repo_name": repo['name'],
            "repo_owner": self.gitea_username
        }

        response = requests.post(
            migration_url,
            headers=self.gitea_headers,
            json=migration_data,
            verify=False
        )

        if response.status_code == 201:
            print(f"Successfully migrated {repo['name']}")
            return True
        else:
            print(f"Failed to migrate {repo['name']}: {response.text}")
            return False

    def run_migration(self):
        """Run the complete migration process"""
        print("Fetching GitHub repositories...")
        repos = self.get_github_repos()
        print(f"Found {len(repos)} repositories")

        successful = 0
        failed = 0

        for repo in repos:
            print(f"\nMigrating {repo['name']}...")
            try:
                if self.migrate_repo(repo):
                    successful += 1
                else:
                    failed += 1
            except Exception as e:
                print(f"Error migrating {repo['name']}: {str(e)}")
                failed += 1
            
            # Add a small delay to avoid rate limiting
            time.sleep(1)

        print(f"\nMigration complete!")
        print(f"Successfully migrated: {successful}")
        print(f"Failed migrations: {failed}")

def main():
    # Get configuration from environment variables
    required_vars = [
        'GITHUB_TOKEN',
        'GITEA_TOKEN',
        'GITEA_URL',
        'GITHUB_USERNAME',
        'GITEA_USERNAME'
    ]
    
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        print("Missing required environment variables:")
        print("\n".join(missing_vars))
        print("\nPlease set these environment variables and try again.")
        return

    migrator = GitHubToGiteaMigrator(
        github_token=os.getenv('GITHUB_TOKEN'),
        gitea_token=os.getenv('GITEA_TOKEN'),
        gitea_url=os.getenv('GITEA_URL'),
        github_username=os.getenv('GITHUB_USERNAME'),
        gitea_username=os.getenv('GITEA_USERNAME')
    )
    
    migrator.run_migration()

if __name__ == "__main__":
    main()