FROM hugomods/hugo:exts as builder

COPY . /src
RUN hugo --minify --enableGitInfo


FROM hugomods/hugo:nginx

COPY --from=builder /src/public /site