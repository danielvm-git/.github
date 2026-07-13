#!/usr/bin/env python3
"""
Migration Status Dashboard — Check which repos have migrated to new CI/CD templates.
Serves at http://localhost:8000/checks
"""
import http.server
import json
import subprocess
import re
from pathlib import Path

PORT = 8000

def get_repos():
    """Get all danielvm-git repos."""
    result = subprocess.run(
        ["gh", "repo", "list", "danielvm-git", "--limit", "50", "--json", "name,hasIssuesEnabled"],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

def check_repo_migration(repo_name):
    """Check if a repo has migrated to new CI/CD templates."""
    # Check for new template files
    result = subprocess.run(
        ["gh", "api", f"repos/danielvm-git/{repo_name}/contents/.github/workflows"],
        capture_output=True, text=True
    )
    
    if result.returncode != 0:
        return {"status": "error", "workflows": [], "migrated": False, "reason": "Cannot access repo"}
    
    try:
        files = json.loads(result.stdout)
        workflow_files = [f["name"] for f in files if f["name"].endswith(('.yml', '.yaml'))]
    except:
        return {"status": "error", "workflows": [], "migrated": False, "reason": "Invalid response"}
    
    # Check for new templates
    new_templates = [f for f in workflow_files if f.startswith('ci-cd-') or f == 'codeql.yml']
    
    # Check for old templates
    old_ci = [f for f in workflow_files if f in ['ci.yml', 'ci.yaml', 'ci-cd.yml'] and not f.startswith('ci-cd-')]
    old_release = [f for f in workflow_files if f in ['release.yml', 'release.yaml', 'release-branch.yml']]
    old_deploy = [f for f in workflow_files if f in ['deploy.yml', 'deploy.yaml', 'deploy-bigbase.yml']]
    old_codeql = [f for f in workflow_files if f.startswith('codeql-') and f != 'codeql.yml']
    
    # Determine migration status
    if new_templates:
        status = "migrated"
        reason = f"Uses new templates: {', '.join(new_templates)}"
    elif old_ci or old_release or old_deploy or old_codeql:
        status = "not_migrated"
        reasons = []
        if old_ci:
            reasons.append(f"Old CI: {', '.join(old_ci)}")
        if old_release:
            reasons.append(f"Old release: {', '.join(old_release)}")
        if old_deploy:
            reasons.append(f"Old deploy: {', '.join(old_deploy)}")
        if old_codeql:
            reasons.append(f"Old CodeQL: {', '.join(old_codeql)}")
        reason = "; ".join(reasons)
    else:
        status = "unknown"
        reason = "No recognizable workflow patterns"
    
    # Check naming convention
    naming_issues = []
    for f in workflow_files:
        # Check if name follows Function (Scope) pattern
        result = subprocess.run(
            ["gh", "api", f"repos/danielvm-git/{repo_name}/contents/.github/workflows/{f}"],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            try:
                content = json.loads(result.stdout).get("content", "")
                import base64
                decoded = base64.b64decode(content).decode('utf-8')
                name_match = re.search(r'^name:\s*(.+)$', decoded, re.MULTILINE)
                if name_match:
                    name = name_match.group(1).strip().strip('"')
                    # Check naming convention
                    if name and not re.match(r'^(CI|CI/CD|CodeQL|Deploy|Release|PR Review)', name):
                        naming_issues.append(f"{f}: '{name}'")
            except:
                pass
    
    return {
        "status": status,
        "workflows": workflow_files,
        "migrated": status == "migrated",
        "reason": reason,
        "naming_issues": naming_issues
    }

def generate_html(repos_status):
    """Generate HTML dashboard."""
    migrated = sum(1 for r in repos_status if r["migrated"])
    not_migrated = sum(1 for r in repos_status if r["status"] == "not_migrated")
    errors = sum(1 for r in repos_status if r["status"] == "error")
    total = len(repos_status)
    
    html = f"""<!DOCTYPE html>
<html>
<head>
    <title>CI/CD Migration Status</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; background: #f5f5f5; }}
        .header {{ background: #24292e; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }}
        .stats {{ display: flex; gap: 20px; margin-bottom: 20px; }}
        .stat {{ background: white; padding: 20px; border-radius: 8px; flex: 1; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }}
        .stat-number {{ font-size: 32px; font-weight: bold; }}
        .stat-label {{ color: #666; margin-top: 5px; }}
        .migrated {{ color: #28a745; }}
        .not-migrated {{ color: #d73a49; }}
        .error {{ color: #6a737d; }}
        table {{ width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }}
        th, td {{ padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }}
        th {{ background: #f6f8fa; font-weight: 600; }}
        tr:hover {{ background: #f6f8fa; }}
        .status-badge {{ padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 500; }}
        .status-migrated {{ background: #28a745; color: white; }}
        .status-not_migrated {{ background: #d73a49; color: white; }}
        .status-error {{ background: #6a737d; color: white; }}
        .status-unknown {{ background: #ffc107; color: black; }}
        .workflows {{ font-size: 12px; color: #666; }}
        .naming-issues {{ font-size: 11px; color: #d73a49; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>CI/CD Migration Status Dashboard</h1>
        <p>Monitoring migration from 16 templates to 9 unified pipelines</p>
    </div>
    
    <div class="stats">
        <div class="stat">
            <div class="stat-number">{total}</div>
            <div class="stat-label">Total Repos</div>
        </div>
        <div class="stat">
            <div class="stat-number migrated">{migrated}</div>
            <div class="stat-label">Migrated</div>
        </div>
        <div class="stat">
            <div class="stat-number not-migrated">{not_migrated}</div>
            <div class="stat-label">Not Migrated</div>
        </div>
        <div class="stat">
            <div class="stat-number error">{errors}</div>
            <div class="stat-label">Errors</div>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Repository</th>
                <th>Status</th>
                <th>Workflows</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
"""
    
    for repo in sorted(repos_status, key=lambda x: (not x["migrated"], x["name"])):
        status_class = f"status-{repo['status']}"
        status_label = repo["status"].replace("_", " ").title()
        
        workflows_html = ", ".join(repo["workflows"][:3])
        if len(repo["workflows"]) > 3:
            workflows_html += f" (+{len(repo['workflows']) - 3} more)"
        
        naming_html = ""
        if repo.get("naming_issues"):
            naming_html = f'<div class="naming-issues">Naming issues: {", ".join(repo["naming_issues"][:2])}</div>'
        
        html += f"""
            <tr>
                <td><strong>{repo['name']}</strong></td>
                <td><span class="status-badge {status_class}">{status_label}</span></td>
                <td class="workflows">{workflows_html}</td>
                <td>{repo['reason']} {naming_html}</td>
            </tr>
"""
    
    html += """
        </tbody>
    </table>
    
    <p style="margin-top: 20px; color: #666; font-size: 12px;">
        Last updated: """ + subprocess.run(["date"], capture_output=True, text=True).stdout.strip() + """
    </p>
</body>
</html>
"""
    return html

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/checks':
            repos = get_repos()
            repos_status = []
            for repo in repos:
                status = check_repo_migration(repo["name"])
                status["name"] = repo["name"]
                repos_status.append(status)
            
            html = generate_html(repos_status)
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(html.encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")

if __name__ == '__main__':
    print(f"Migration Dashboard running at http://localhost:{PORT}/checks")
    server = http.server.HTTPServer(('localhost', PORT), Handler)
    server.serve_forever()
