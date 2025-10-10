# How to Push to GitHub

## 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `dutch-parliament-electoral-cycle-analysis` (or your choice)
3. Description: "Network analysis of Dutch parliamentary co-voting patterns across the electoral cycle (2023-2024)"
4. **Keep it PUBLIC** (or private if preferred)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

## 2. Push Your Local Repository

Copy and run these commands in your terminal:

```bash
cd "/Users/loesvanvoorden/Library/CloudStorage/OneDrive-Personal/MSc JADS/JADS year 1/3 SNA 2/group_project_sna"

# Add GitHub as remote (replace YOUR-USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR-USERNAME/REPOSITORY-NAME.git

# Push to GitHub
git push -u origin main
```

## 3. Verify

- Go to your GitHub repository URL
- You should see all files, including:
  - README.md (with project description)
  - data/, scripts/, results/ folders
  - .gitignore (protecting temporary files)

## Example Commands

If your GitHub username is `johndoe` and repo name is `dutch-parliament-analysis`:

```bash
git remote add origin https://github.com/johndoe/dutch-parliament-analysis.git
git push -u origin main
```

## Troubleshooting

### Authentication Error
If you get authentication errors:
1. Go to GitHub Settings → Developer Settings → Personal Access Tokens
2. Generate new token (classic) with `repo` permissions
3. Use the token as your password when prompted

### Files Too Large
If data files are too large for GitHub:
1. Consider using Git LFS: `git lfs install`
2. Or add large data files to .gitignore
3. Upload data separately (e.g., to OSF, Zenodo)

---

✅ **Your repository is ready to push!**

