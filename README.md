![Photo Stream Social Preview](https://raw.githubusercontent.com/waschinski/photo-stream/master/social-preview.png)

# Photo Stream

Photo Stream is a simple, self-hosted photo gallery for publishing your own photo stream without tracking or a hosted social platform.

This repository is a maintained fork of the original Photo Stream project. The fork focuses on container support, dependency updates, safer defaults, and small runtime fixes while preserving the original static Jekyll photo-stream experience.

## Disclaimer And Credits

This fork was updated with assistance from AI tooling. The AI-assisted changes are limited to maintenance work such as dependency updates, Docker hardening, documentation cleanup, and small code fixes.

All original project credit belongs to the original Photo Stream authors and contributors, including [@maxvoltar](https://github.com/maxvoltar), [@waschinski](https://github.com/waschinski), [@boerniee](https://github.com/boerniee), and the upstream [Photo Stream contributors](https://github.com/waschinski/photo-stream/graphs/contributors). This fork does not claim authorship of the original project.

Demo photos included with the original project are credited to [Carrie Cronan](https://unsplash.com/@ccronan).

## Features

- Self-hosted static photo stream
- Lazy-loaded photo grid
- Larger image versions loaded only when needed
- PNG, JPG, JPEG, GIF, and WebP support
- Generated thumbnail, large, and tint image variants
- Photo detail pages with unique URLs
- Keyboard navigation
- Optional sharing and original-download links
- Optional RSS feed
- Light and dark theme support
- Docker and GitHub Container Registry support

## Container Image

This fork publishes a hardened container image to GitHub Container Registry on pushes to `master`.

Pull the latest image:

```sh
docker pull ghcr.io/doubtfulturnip/photo-stream:latest
```

The image is also tagged by branch, tag, and commit SHA through the GitHub Actions workflow in `.github/workflows/docker-publish.yml`.

## Quick Start With Docker Compose

Copy the example environment file:

```sh
cp .env.example .env
```

Edit `.env` for your site title, URL, author details, and feature flags.

Place original photos in:

```text
photos/original/
```

Start the app:

```sh
docker compose up -d
```

Open:

```text
http://localhost:4000
```

The compose file builds the local Dockerfile by default so local changes are used automatically. To use the published GHCR image instead, replace the `build:` section in `docker-compose.yml` with:

```yaml
image: ghcr.io/doubtfulturnip/photo-stream:latest
```

## Running With Docker Directly

```sh
docker run -d \
  --name photo-stream \
  --env-file .env \
  -v "$(pwd)/photos:/photo-stream/photos" \
  -p 4000:4000 \
  ghcr.io/doubtfulturnip/photo-stream:latest
```

On Windows PowerShell, use an absolute path for the volume mount:

```powershell
docker run -d `
  --name photo-stream `
  --env-file .env `
  -v "D:\Path\To\photo-stream\photos:/photo-stream/photos" `
  -p 4000:4000 `
  ghcr.io/doubtfulturnip/photo-stream:latest
```

## Configuration

Configuration is provided through `.env`. Start from `.env.example`.

Common settings:

- `TITLE`: Site title.
- `DESCRIPTION`: Site description.
- `URL`: Public site URL. Do not end this with `/`.
- `AUTHOR_NAME`: Author name for metadata and feeds.
- `AUTHOR_EMAIL`: Optional author email.
- `AUTHOR_WEBSITE`: Optional author website.
- `PHOTO_PATH`: Host path mounted to `/photo-stream/photos` when using Compose.
- `SHOW_RSS_FEED`: Set `1` to show the RSS feed link.
- `SHOW_OFFICIAL_GITHUB`: Set `1` to show the upstream GitHub link.
- `HEADER_ENABLED`: Set `1` to show the page header.
- `ALLOW_ORDER_SORT_CHANGE`: Set `1` to allow users to reverse photo order.
- `DEFAULT_REVERSE_SORT`: Set `1` to show oldest photos first.
- `ALLOW_ORIGINAL_DOWNLOAD`: Set `1` to allow downloads of original images.
- `ALLOW_INDEXING`: Set `0` to add `noindex`.
- `ALLOW_IMAGE_SHARING`: Set `1` to enable share links.
- `TWITTER_USERNAME`, `GITHUB_USERNAME`, `INSTAGRAM_USERNAME`: Optional social links.
- `CUSTOM_LINK_NAME`, `CUSTOM_LINK_URL`: Optional custom footer link.

Deployment script settings are still available for the original shell scripts:

- `SYNCUSER`
- `SYNCPASS`
- `SYNCSERVER`
- `SYNCFOLDER`

## Photo Workflow

Add original image files to:

```text
photos/original/
```

File names become photo titles and URL slugs. For example:

```text
photos/original/Sunset Over The Bay.jpg
```

becomes a photo page with a slug similar to:

```text
/sunset-over-the-bay/
```

During the Jekyll build, Photo Stream generates:

- `photos/large`: Large display images.
- `photos/thumbnail`: Grid thumbnails.
- `photos/tint`: Tiny tint placeholders and photo-page backgrounds.

Do not manually edit generated image folders unless you know you want to discard and regenerate them.

## Building Locally

The Docker path is recommended because image processing dependencies are easier to keep consistent there.

Build the image:

```sh
docker build -t photo-stream:dev .
```

Run a static build:

```sh
docker run --rm \
  --env-file .env \
  -v "$(pwd)/photos:/photo-stream/photos" \
  --entrypoint bundle \
  photo-stream:dev \
  exec jekyll build
```

Serve locally:

```sh
docker run --rm \
  --env-file .env \
  -v "$(pwd)/photos:/photo-stream/photos" \
  -p 4000:4000 \
  photo-stream:dev
```

## Manual Ruby Setup

Manual Ruby setup is possible, but less predictable because native image-processing gems need system libraries.

Requirements:

- Ruby 3.1 or newer, below Ruby 3.5
- Bundler
- Build tools
- libvips
- ExifTool

Install gems:

```sh
bundle install
```

Serve:

```sh
bundle exec jekyll serve
```

Build static output:

```sh
bundle exec jekyll build
```

The generated static site is written to `_site/`.

## Security Notes

This fork includes a few hardening changes:

- `.env` is ignored and `.env.example` is committed instead.
- The Docker image uses a multi-stage build.
- Build tools are not included in the runtime image.
- The runtime container runs as an unprivileged `photo-stream` user.
- Docker Compose drops Linux capabilities and sets `no-new-privileges`.
- Ruby advisory checks were used to update vulnerable dependencies.

Important operational notes:

- Only trusted users should be able to add files to `photos/original`.
- Image and EXIF parsing can expose native libraries to malformed files.
- For public internet hosting, serving the generated `_site/` directory behind a standard web server or CDN is safer than exposing Jekyll/WEBrick directly.
- Keep rebuilding the image regularly so Alpine and Ruby package updates are picked up.

## GitHub Actions

The Docker publish workflow builds and publishes to GHCR when changes are pushed to `master`, when version tags are pushed, or when the workflow is run manually.

Published tags include:

- `latest`
- branch name
- Git tag
- commit SHA

## License

This fork preserves the original project's license. See `LICENSE`.

## Upstream

Original project:

```text
https://github.com/waschinski/photo-stream
```
