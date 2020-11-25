# `dataops-infra` Auto-Docs

_These documents are published automatically to [infra.dataops.tk](https://infra.dataops.tk) using [Github Pages](https://help.github.com/en/github/working-with-github-pages) and [Jekyll](https://jekyllrb.com/docs/)._

## Dependencies

```bash
pip3 install uio logless runnow
brew install terraform-docs
```

## Rebuilding Docs


To rebuild or update all module README docs, run the following command on your dev machine:

```bash
cd autodocs
python build.py
```

To provide additional documentation for a module, you may optionally publish additional documentation into a `USAGE.md` or `NOTES.md` file. If one or both of these files exist within a module folder, the content from the additional file(s) will be automatically added into the auto-generated README.md.

## Local Testing

To test the docs website locally, follow instructions here: [Testing your GitHub pages site locally with Jekyll](https://help.github.com/en/github/working-with-github-pages/testing-your-github-pages-site-locally-with-jekyll)
