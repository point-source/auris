# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Live web demo

Host the showcase example as a public web app on GitHub Pages, auto-deployed
on every push to `main` and linked from the README, so prospects can try the
real widgets in a browser before adopting (§spec:live-demo).

### §road:example-responsive-layout

Make the showcase reflow to the viewport so it is legible on a phone browser
without horizontal scrolling, in `example/lib/main.dart` (§spec:live-demo).

### §road:web-deploy-workflow

Add a GitHub Actions workflow that builds the example for web with base href
`/auris/` and deploys it to GitHub Pages on every push to `main`, gated so a
failed build fails before publishing and leaves the last good deploy live, in
`.github/workflows/` (§spec:live-demo). One-time repo setting: Pages source =
GitHub Actions.

### §road:readme-demo-link

Add a prominent "Live demo" link near the top of `README.md` pointing at the
deployed Pages URL (§spec:live-demo). Depends on §road:web-deploy-workflow.

**Verify:** Open `https://point-source.github.io/auris/` in a desktop browser
and a phone browser; interact with the showcase (flip the accent, drag the
bevel/glow sliders) and confirm the widgets respond and the layout is legible
with no horizontal scroll on the phone. From the top of the README, click the
live-demo link and confirm it lands on the running demo. Push a trivial change
to `main`, wait for the deploy, and confirm the live site reflects it; then
push a deliberately broken example build and confirm the job fails and the
previously deployed site is still served.
