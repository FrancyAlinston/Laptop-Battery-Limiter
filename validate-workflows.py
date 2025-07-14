#!/usr/bin/env python3
"""
GitHub Workflows Validation Script
Validates YAML syntax and basic structure of GitHub Actions workflows
"""

import yaml
import sys
import os
from pathlib import Path

def validate_workflow(file_path):
    """Validate a GitHub workflow file"""
    print(f"\n🔍 Validating {file_path}...")
    
    try:
        with open(file_path, 'r') as f:
            content = yaml.safe_load(f)
        
        # Check basic structure - handle 'on' being parsed as boolean True
        required_keys = ['name', 'jobs']
        trigger_key = True if True in content else 'on'  # YAML parses 'on:' as True
        
        for key in required_keys:
            if key not in content:
                print(f"❌ Missing required key: {key}")
                return False
        
        if trigger_key not in content:
            print(f"❌ Missing trigger configuration")
            return False
        
        # Check jobs structure
        jobs = content['jobs']
        if not isinstance(jobs, dict) or not jobs:
            print(f"❌ No jobs defined")
            return False
        
        # Validate each job
        for job_name, job_config in jobs.items():
            if 'runs-on' not in job_config:
                print(f"❌ Job '{job_name}' missing 'runs-on'")
                return False
            
            if 'steps' not in job_config:
                print(f"❌ Job '{job_name}' missing 'steps'")
                return False
        
        print(f"✅ {file_path} is valid")
        print(f"📊 Found {len(jobs)} jobs: {', '.join(jobs.keys())}")
        return True
        
    except yaml.YAMLError as e:
        print(f"❌ YAML syntax error: {e}")
        return False
    except Exception as e:
        print(f"❌ Error validating: {e}")
        return False

def main():
    """Main validation function"""
    print("🚀 GitHub Workflows Validator")
    print("=" * 50)
    
    workflows_dir = Path(".github/workflows")
    if not workflows_dir.exists():
        print("❌ No .github/workflows directory found")
        sys.exit(1)
    
    workflow_files = list(workflows_dir.glob("*.yml")) + list(workflows_dir.glob("*.yaml"))
    
    if not workflow_files:
        print("❌ No workflow files found")
        sys.exit(1)
    
    print(f"📁 Found {len(workflow_files)} workflow files")
    
    all_valid = True
    for workflow_file in workflow_files:
        if not validate_workflow(workflow_file):
            all_valid = False
    
    print("\n" + "=" * 50)
    if all_valid:
        print("🎉 All workflows are valid!")
        sys.exit(0)
    else:
        print("❌ Some workflows have issues")
        sys.exit(1)

if __name__ == "__main__":
    main()
