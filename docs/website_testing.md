# [Slalom DataOps Infrastructure Catalog](../README.md) > Website Testing

Instructions to test the GitHub Pages website generation.

1. Installation
   1. Install Ruby: `choco install ruby`
   2. Install `jekyll` Gem: `gem install jekyll -v 3.9.0` (or whatever version is listed [here](https://pages.github.com/versions/))
   3. Install `github-pages` Gem: `gem install github-pages`
   4. Run `bundle update` to refresh and update package versions.
   5. Run `bundle exec jekyll serve --incremental` to test the site locally.
      - Most types of content changes will be hot-refreshed, automatically updated
        when they are changed.

## List of Important Config Files

1. `/_config.yml` - The base configuration for the Jekyll website.
2. `/_includes/` - Folder to override theme files.
3. `404.html` - The page template to use for 404 errors (page not found).
4. `about.md` - The content of the about page.
5. `Gemfile` - Ruby project configuration (used by Jekyll).
6. `Gemfile.lock` - Ruby version lock file, used to prevent version conflicts.
