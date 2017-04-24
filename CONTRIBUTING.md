# Contributing to lepidopter

Lepidopter is a Free and Open Source software project that welcomes
new contributions.

### 1. Fork

You should first create a fork of lepidopter by clicking on the fork button
and cloning your fork with:

```
git clone git@github.com:username/lepidopter.git
cd lepidopter
git remote add upstream https://github.com/TheTorProject/lepidopter.git
```

### 2. Branch

Branches should be created from the `master` branch with an accurately
labelled name.

If you want to work on a new feature you could name your branch
`feature/myfeature`, if you are fixing a bug you could name it `bug/1234`.

Create your branch from `master` like so:

```
git checkout -b mybranch
```

Then you can start hacking

### 3. Commit

Make sure git knows your username and email address with the following:

```
git config --global user.name "Jane Doe"
git config --global user.email "jane@example.com"
```

Try to keep the commits made on the branch small (a good branch should only
address one specific issue).

### 4. Open a Pull Request

You can then push your feature branch to your remote and open a pull request.

## Code Review process

Small pull requests should be tagged as `hotfix` and can be self
merged. All other pull request should be reviewed by another core
developer who will take responsibility of the merge. The repository
should be configured such that it is not possible to merge into
`master` (or `stable`) if unit tests are not passing.

If the diff is small, squash merge is preferred, otherwise preserve
the history.  In general it is a good idea to keep your branches
in sync with master and rebase them from time to time before the
review has happened. However if the review has already begun it's
better to merge and resolve the conflicts locally and push the merge
commit, to allow the reviewer to see how the conflicts were resolved.

Before a release, review the code base, fixing simple bugs directly
and opening issues to describe more complex required fixes and
refactoring opportunities. Also during such review make sure that
the documentation is up to date with the code.
