---
name: Release checklist
about: Checklist for a pipeline release
title: 'Release v'
labels: release
assignees: mgalloy

---

### Pre-release check

- [ ] check to make sure no changes to the production config files are needed
- [ ] add date to version line in `RELEASES.md`
- [ ] check that version to release in `RELEASES.md` matches version in `CMakeLists.txt`

### Release to production

- [ ] merge master to production
- [ ] push production to origin
- [ ] tag production
- [ ] push tags

### Install production

- [ ] pull at `/hao/acos/sw/src/ucomp-pipeline`
- [ ] run `production_configure.sh`
- [ ] `cd build; make`
- [ ] `make install` when the pipeline is not running

### Post-release check

- [ ] send email with new release notes to iguana, detoma, and observers
- [ ] in master, increment version in `CMakeLists.txt` and `RELEASES.md`

### Install at MLSO

A day after production release, release to MLSO.

- [ ] pull at MLSO
- [ ] run `mlso_configure.sh`
- [ ] `cd build; make`
- [ ] `make install` when the pipeline is not running
