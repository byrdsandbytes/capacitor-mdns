# Contributing

Thanks for helping improve `@byrds/capacitor-mdns`.

## Local Checks

Run the same checks before opening a pull request:

```bash
npm run build
npm run lint
npm test
npm run verify:android
```

`npm test` runs the Electron e2e flow, which publishes a local mDNS service, discovers it, and
stops it again. Android and iOS native runtime behavior still depends on real devices or platform
simulators because local-network permissions and multicast routing vary by environment.

## Documentation

The API section in `README.md` is generated from `src/definitions.ts`.

```bash
npm run docgen
```

Update the JSDoc comments first, then regenerate the README.

## Publishing to npm

To publish a new release:

1. Ensure working directory is clean and all checks pass (`npm run lint`, `npm run build`).
2. Bump version:
   ```bash
   npm version patch # or minor, major
   ```
3. Run publish command:
   ```bash
   npm run release
   ```
   This triggers `npm run build` via `prepublishOnly` and publishes the package with public access.
4. Push git commit and tags:
   ```bash
   git push && git push --tags
   ```
