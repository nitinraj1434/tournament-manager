# 🌐 GitHub Pages Hosting Guide

## Quick Steps to Host Your Website & Privacy Policy

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `tournament-manager-website`
3. Set to **Public**
4. Click **"Create repository"**

### Step 2: Upload Files

**Option A: Via Web Interface (Easiest)**

1. In your new repo, click **"uploading an existing file"**
2. Drag and drop these files from `docs` folder:
   - `index.html`
   - `privacy-policy.html`
3. Scroll down and click **"Commit changes"**

**Option B: Via Git Commands**

```powershell
cd c:\Users\Nitin\OneDrive\Desktop\turnament\docs

git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/tournament-manager-website.git
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to repository **Settings**
2. Scroll to **"Pages"** section (left sidebar)
3. Under **"Source"**, select:
   - Branch: `main`
   - Folder: `/ (root)`
4. Click **"Save"**
5. Wait 1-2 minutes

### Step 4: Get Your URLs

Your website will be live at:

```
Website URL: https://YOUR_USERNAME.github.io/tournament-manager-website/
Privacy Policy URL: https://YOUR_USERNAME.github.io/tournament-manager-website/privacy-policy.html
```

Replace `YOUR_USERNAME` with your GitHub username.

### Step 5: Update Form

Once URLs are live, update the Indus App Store form:
- Website URL: Your GitHub Pages URL
- Privacy Policy URL: Your GitHub Pages privacy policy URL

---

## Alternative: Firebase Hosting (If you have Node.js)

If you have Node.js installed:

```powershell
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
cd c:\Users\Nitin\OneDrive\Desktop\turnament
firebase init hosting

# Select your Firebase project
# Set public directory: docs
# Configure as single-page app: No
# Don't overwrite files

# Deploy
firebase deploy --only hosting

# Your URLs will be:
# https://YOUR_PROJECT_ID.web.app/
# https://YOUR_PROJECT_ID.web.app/privacy-policy.html
```

---

## Temporary Solution (Quick!)

For now, you can use these placeholder URLs in the form:
- Website: `https://tournamentmanager.com` (placeholder)
- Privacy Policy: `https://tournamentmanager.com/privacy` (placeholder)

**WARNING:** App might get rejected if URLs don't work. Best to use GitHub Pages!

---

## Files Ready in `docs` folder:

```
turnament/docs/
  ├── index.html (Landing page)
  └── privacy-policy.html (Privacy policy)
```

Upload these to GitHub Pages for instant hosting!
