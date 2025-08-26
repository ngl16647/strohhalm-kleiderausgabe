# strohhalm-kleiderausgabe
Eine Anwendung für den Strohhalm e. V. für die Aufnahme, Pflege und ggf. Analyse der Daten.

---

# Guidelines for the devs
## Branches
- **main** → contains fully working version
- **dev** → where active development happens.  

## Use your own Branch 
When working, create a branch off **dev**. Once you are done with your **feature/bugfix** you can merge your branch into dev.
```
git checkout dev
git pull origin dev
git checkout -b feature/your-task-name
```

## Keep your branch up to date
Before merging your branch into dev, make sure you rebased to avoid merge conflicts.
```
git fetch origin
git rebase origin/dev
```

## Commit Messages
- Keep commit messages **short and clear**.  
- Describe **what the commit does**, not how.  
- Examples:  
  - `update .gitignore`  

## Summary
1. Work on your own branch.  
2. Rebase onto `dev` before merging.  
3. Merge into `dev`.  
4. `main` gets updated once `dev` is tested and stable.  