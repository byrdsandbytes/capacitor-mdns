# capacitor-mdns (a @devioarts/capacitor-mdns fork)

mDNS plugin for Capacitor that supports Bonjour/mDNS advertisements and discovery on iOS,
Android, Electron, and a safe web fallback.

#### Supported platforms: &#x2713; iOS &#x2713; Android &#x2713; Electron &#x2713; Web fallback

The in-repository [`playground`](./playground) is the example app used during development.

## Install

```bash
npm install @byrds/capacitor-mdns
npx cap sync
```

## Usage

### One-shot Advertising & Discovery

```ts
import { mDNS } from '@byrds/capacitor-mdns';

const runtime = await mDNS.getPluginPlatform();

// Start advertising
await mDNS.startBroadcast({ type: '_http._tcp.', name: 'MyService', port: 9100 });

// Discover services of a given type (timeboxed)
const result = await mDNS.discover({ type: '_http._tcp.', timeout: 3000 });

// Stop advertising
await mDNS.stopBroadcast();
```

### Watching Multiple Services Simultaneously

Use `watchServices` to continuously monitor multiple service types at once with event listeners:

```ts
import { mDNS } from '@byrds/capacitor-mdns';

// 1. Listen for newly discovered services
const foundSub = await mDNS.addListener('serviceFound', ({ service }) => {
  console.log(`Discovered ${service.type}: ${service.name} at ${service.hosts.join(', ')}:${service.port}`);
});

// 2. Listen for vanished services
const lostSub = await mDNS.addListener('serviceLost', ({ service }) => {
  console.log(`Lost service: ${service.name} (${service.type})`);
});

// 3. Start watching multiple service types at once
const result = await mDNS.watchServices({
  types: ['_http._tcp.', '_airplay._tcp.', '_googlecast._tcp.']
});
console.log(`Started ${result.watchersStarted} service watchers`);

// 4. When done, stop watching and remove listeners
await mDNS.stopWatching();
await foundSub.remove();
await lostSub.remove();
```

## Platform Setup

Android requires mDNS/network permissions in `AndroidManifest.xml`; the plugin also declares them
so they are merged during sync. iOS requires local network keys in `Info.plist`.
Electron support is intended for [`devioarts/capacitor-electron`](https://github.com/devioarts/capacitor-electron)
and uses metadata exported from `@devioarts/capacitor-mdns/electron/settings`.

Detailed setup lives in:

- [iOS and Android setup](./docs/platform-setup.md)
- [Electron setup](./docs/electron.md)
- [Playground](./docs/playground.md)
- [Runtime behavior](./docs/runtime-behavior.md)

## Publishing to npm

To release and publish a new version of `@byrds/capacitor-mdns` to npm:

1. **Verify checks and linting pass:**
   ```bash
   npm run lint
   npm run build
   ```

2. **Bump the package version:**
   ```bash
   npm version patch   # or minor, major
   ```

3. **Publish to npm:**
   ```bash
   npm run release
   ```
   > **Note:** The `release` script executes `npm publish --access public`, which automatically triggers `prepublishOnly` (`npm run build`) to clean, regenerate API documentation via `docgen`, compile TypeScript, and produce the Rollup bundles.

4. **Push commits and tags to remote repository:**
   ```bash
   git push && git push --tags
   ```

## API

<docgen-index>

* [`getPluginPlatform()`](#getpluginplatform)
* [`startBroadcast(...)`](#startbroadcast)
* [`stopBroadcast()`](#stopbroadcast)
* [`discover(...)`](#discover)
* [`watchServices(...)`](#watchservices)
* [`stopWatching()`](#stopwatching)
* [`addListener('serviceFound', ...)`](#addlistenerservicefound-)
* [`addListener('serviceLost', ...)`](#addlistenerservicelost-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Public API surface of the Capacitor mDNS plugin.

### getPluginPlatform()

```typescript
getPluginPlatform() => Promise<MdnsPluginPlatformResult>
```

Return the platform implementation currently serving plugin calls.

**Returns:** <code>Promise&lt;<a href="#mdnspluginplatformresult">MdnsPluginPlatformResult</a>&gt;</code>

--------------------


### startBroadcast(...)

```typescript
startBroadcast(options: MdnsBroadcastOptions) => Promise<MdnsBroadcastResult>
```

Start advertising a Bonjour/mDNS service.

| Param         | Type                                                                  | Description                                                        |
| ------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **`options`** | <code><a href="#mdnsbroadcastoptions">MdnsBroadcastOptions</a></code> | - {@link <a href="#mdnsbroadcastoptions">MdnsBroadcastOptions</a>} |

**Returns:** <code>Promise&lt;<a href="#mdnsbroadcastresult">MdnsBroadcastResult</a>&gt;</code>

--------------------


### stopBroadcast()

```typescript
stopBroadcast() => Promise<MdnsStopResult>
```

Stop advertising the currently registered service (no-op if none).

**Returns:** <code>Promise&lt;<a href="#mdnsstopresult">MdnsStopResult</a>&gt;</code>

--------------------


### discover(...)

```typescript
discover(options?: MdnsDiscoverOptions | undefined) => Promise<MdnsDiscoverResult>
```

Discover services of a given type and optionally filter by instance name.

| Param         | Type                                                                | Description                                                      |
| ------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **`options`** | <code><a href="#mdnsdiscoveroptions">MdnsDiscoverOptions</a></code> | - {@link <a href="#mdnsdiscoveroptions">MdnsDiscoverOptions</a>} |

**Returns:** <code>Promise&lt;<a href="#mdnsdiscoverresult">MdnsDiscoverResult</a>&gt;</code>

--------------------


### watchServices(...)

```typescript
watchServices(options: MdnsWatchOptions) => Promise<MdnsWatchResult>
```

Start watching for one or more service types continuously.
Services are reported as they appear and disappear via the
`serviceFound` and `serviceLost` events.

| Param         | Type                                                          | Description                                                |
| ------------- | ------------------------------------------------------------- | ---------------------------------------------------------- |
| **`options`** | <code><a href="#mdnswatchoptions">MdnsWatchOptions</a></code> | - {@link <a href="#mdnswatchoptions">MdnsWatchOptions</a>} |

**Returns:** <code>Promise&lt;<a href="#mdnswatchresult">MdnsWatchResult</a>&gt;</code>

--------------------


### stopWatching()

```typescript
stopWatching() => Promise<MdnsStopResult>
```

Stop all active service watchers started by {@link watchServices}.
Safe to call even when no watchers are active.

**Returns:** <code>Promise&lt;<a href="#mdnsstopresult">MdnsStopResult</a>&gt;</code>

--------------------


### addListener('serviceFound', ...)

```typescript
addListener(eventName: 'serviceFound', handler: (event: MdnsServiceEvent) => void) => Promise<PluginListenerHandle>
```

Listen for service discovery events during active watching.

| Param           | Type                                                                              | Description                                                                        |
| --------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **`eventName`** | <code>'serviceFound'</code>                                                       | - `'serviceFound'` when a new service is discovered.                               |
| **`handler`**   | <code>(event: <a href="#mdnsserviceevent">MdnsServiceEvent</a>) =&gt; void</code> | - Callback receiving the {@link <a href="#mdnsserviceevent">MdnsServiceEvent</a>}. |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('serviceLost', ...)

```typescript
addListener(eventName: 'serviceLost', handler: (event: MdnsServiceEvent) => void) => Promise<PluginListenerHandle>
```

Listen for service loss events during active watching.

| Param           | Type                                                                              | Description                                                                        |
| --------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **`eventName`** | <code>'serviceLost'</code>                                                        | - `'serviceLost'` when a previously discovered service disappears.                 |
| **`handler`**   | <code>(event: <a href="#mdnsserviceevent">MdnsServiceEvent</a>) =&gt; void</code> | - Callback receiving the {@link <a href="#mdnsserviceevent">MdnsServiceEvent</a>}. |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

Remove all listeners registered by this plugin.

--------------------


### Interfaces


#### MdnsPluginPlatformResult

Result of getPluginPlatform(). Useful for validating that calls are routed
through the expected platform bridge.

| Prop           | Type                                                              | Description                                        |
| -------------- | ----------------------------------------------------------------- | -------------------------------------------------- |
| **`platform`** | <code><a href="#mdnspluginplatform">MdnsPluginPlatform</a></code> | Platform implementation that produced this result. |


#### MdnsBroadcastResult

Result of startBroadcast(). Indicates whether advertising is active
and the final service name. On failure, `error` is true and `errorMessage`
describes the issue.

| Prop               | Type                        | Description                                                          |
| ------------------ | --------------------------- | -------------------------------------------------------------------- |
| **`error`**        | <code>boolean</code>        | True if the operation failed.                                        |
| **`errorMessage`** | <code>string \| null</code> | Error description or null on success.                                |
| **`name`**         | <code>string</code>         | Final (possibly uniquified) service instance name. Empty on failure. |
| **`publishing`**   | <code>boolean</code>        | Whether the advertiser is currently active.                          |


#### MdnsBroadcastOptions

Options for starting a Bonjour/mDNS advertisement.

| Prop       | Type                                        | Description                                   |
| ---------- | ------------------------------------------- | --------------------------------------------- |
| **`type`** | <code>string</code>                         | Service type (including the trailing dot).    |
| **`name`** | <code>string</code>                         | Service instance name.                        |
| **`port`** | <code>number</code>                         | TCP port to advertise.                        |
| **`txt`**  | <code><a href="#mdnstxt">MdnsTxt</a></code> | Optional TXT key–value pairs (UTF-8 strings). |


#### MdnsStopResult

Result of stopBroadcast(). Indicates whether the advertiser is active
after the call (normally false) and includes error information.

| Prop               | Type                        | Description                                                         |
| ------------------ | --------------------------- | ------------------------------------------------------------------- |
| **`error`**        | <code>boolean</code>        | True if an error occurred while stopping.                           |
| **`errorMessage`** | <code>string \| null</code> | Error description or null on success.                               |
| **`publishing`**   | <code>boolean</code>        | Whether the advertiser remains active (should be false on success). |


#### MdnsDiscoverResult

Result of discover(). Contains normalized services and error information.

| Prop                | Type                        | Description                                                                    |
| ------------------- | --------------------------- | ------------------------------------------------------------------------------ |
| **`error`**         | <code>boolean</code>        | True if discovery encountered an error (partial results may still be present). |
| **`errorMessage`**  | <code>string \| null</code> | Error description or null when no error occurred.                              |
| **`servicesFound`** | <code>number</code>         | Convenience count equal to services.length.                                    |
| **`services`**      | <code>MdnsService[]</code>  | Normalized list of discovered services.                                        |


#### MdnsService

Normalized description of a discovered Bonjour/mDNS service.
Returned from {@link mDNSPlugin.discover}.

| Prop           | Type                                        | Description                                                                               |
| -------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **`name`**     | <code>string</code>                         | Instance name of the service (may be uniqued by the OS, e.g. "My App (2)").               |
| **`type`**     | <code>string</code>                         | Full service type including the trailing dot, e.g. `"_http._tcp."`.                       |
| **`domain`**   | <code>string</code>                         | Service domain; typically `"local."`.                                                     |
| **`port`**     | <code>number</code>                         | TCP port the service advertises.                                                          |
| **`hosts`**    | <code>string[]</code>                       | Resolved numeric IP addresses (IPv4/IPv6).                                                |
| **`hostname`** | <code>string</code>                         | The host name, e.g. `"my-device.local."`.                                                 |
| **`txt`**      | <code><a href="#mdnstxt">MdnsTxt</a></code> | TXT dictionary (key → value). Usually present on iOS; Android NSD does not populate this. |


#### MdnsDiscoverOptions

Options for Bonjour/mDNS discovery.

| Prop          | Type                 | Description                                                      |
| ------------- | -------------------- | ---------------------------------------------------------------- |
| **`type`**    | <code>string</code>  | Service type (including the trailing dot).                       |
| **`name`**    | <code>string</code>  | Optional instance name filter (prefix-safe).                     |
| **`timeout`** | <code>number</code>  | Discovery timeout in milliseconds.                               |
| **`useNW`**   | <code>boolean</code> | iOS-only hint to use `NWBrowser` instead of `NetServiceBrowser`. |


#### MdnsWatchResult

Result of watchServices(). Indicates how many watchers were started
and whether an error occurred.

| Prop                  | Type                        | Description                                 |
| --------------------- | --------------------------- | ------------------------------------------- |
| **`error`**           | <code>boolean</code>        | True if the operation encountered an error. |
| **`errorMessage`**    | <code>string \| null</code> | Error description or null on success.       |
| **`watchersStarted`** | <code>number</code>         | Number of watchers successfully started.    |


#### MdnsWatchOptions

Options for starting continuous service watching.

| Prop        | Type                  | Description                            |
| ----------- | --------------------- | -------------------------------------- |
| **`types`** | <code>string[]</code> | Service types to watch simultaneously. |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### MdnsServiceEvent

Payload emitted by the `serviceFound` and `serviceLost` events
during active service watching.

| Prop          | Type                                                | Description                              |
| ------------- | --------------------------------------------------- | ---------------------------------------- |
| **`service`** | <code><a href="#mdnsservice">MdnsService</a></code> | The service that was discovered or lost. |


### Type Aliases


#### MdnsPluginPlatform

Runtime implementation that handled a plugin call.

<code>'ios' | 'android' | 'electron' | 'web'</code>


#### MdnsTxt

Key–value map for TXT records of a Bonjour/mDNS service.
Values are UTF-8 strings; binary payloads are not supported by this API.

<code><a href="#record">Record</a>&lt;string, string&gt;</code>


#### Record

Construct a type with a set of properties K of type T

<code>{ [P in K]: T; }</code>

</docgen-api>
