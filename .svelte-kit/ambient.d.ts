
// this file is generated — do not edit it


/// <reference types="@sveltejs/kit" />

/**
 * Environment variables [loaded by Vite](https://vitejs.dev/guide/env-and-mode.html#env-files) from `.env` files and `process.env`. Like [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), this module cannot be imported into client-side code. This module only includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured).
 * 
 * _Unlike_ [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), the values exported from this module are statically injected into your bundle at build time, enabling optimisations like dead code elimination.
 * 
 * ```ts
 * import { API_KEY } from '$env/static/private';
 * ```
 * 
 * Note that all environment variables referenced in your code should be declared (for example in an `.env` file), even if they don't have a value until the app is deployed:
 * 
 * ```
 * MY_FEATURE_FLAG=""
 * ```
 * 
 * You can override `.env` values from the command line like so:
 * 
 * ```sh
 * MY_FEATURE_FLAG="enabled" npm run dev
 * ```
 */
declare module '$env/static/private' {
	export const PUID: string;
	export const PGID: string;
	export const UMASK: string;
	export const CONTAINER_PREFIX: string;
	export const CONFIG_PATH: string;
	export const DATA_PATH: string;
	export const TZ: string;
	export const RESTART_POLICY: string;
	export const NETWORK_MODE: string;
	export const HOST: string;
	export const BASE_DOMAIN: string;
	export const TAG: string;
	export const DOT_TCP_PORT: string;
	export const DOT_UDP_PORT: string;
	export const DOQ_PORT: string;
	export const DTLS_PORT: string;
	export const METRICS_OTLP: string;
	export const TRACING_OTLP: string;
	export const INSECURE_OTLP: string;
	export const CF_ENABLED: string;
	export const CLOUDFLARE_DNS_API_TOKEN: string;
	export const CF_ZONE_ID: string;
	export const CF_TUNNEL_ID: string;
	export const CF_ACCOUNT_ID: string;
	export const CF_TUNNEL_SECRET: string;
	export const CF_API_EMAIL: string;
	export const ACME_CA_SERVER: string;
	export const AUTO_UPDATE: string;
	export const GOTIFY_URL: string;
	export const GOFITY_TOKEN: string;
	export const TERM_PROGRAM: string;
	export const NODE: string;
	export const SHELL: string;
	export const TERM: string;
	export const TMPDIR: string;
	export const VSCODE_PYTHON_AUTOACTIVATE_GUARD: string;
	export const TERM_PROGRAM_VERSION: string;
	export const ORIGINAL_XDG_CURRENT_DESKTOP: string;
	export const _tide_color_separator_same_color: string;
	export const FIG_NEW_SESSION: string;
	export const MallocNanoZone: string;
	export const npm_config_local_prefix: string;
	export const USER: string;
	export const COMMAND_MODE: string;
	export const SSH_AUTH_SOCK: string;
	export const __CF_USER_TEXT_ENCODING: string;
	export const npm_execpath: string;
	export const PATH: string;
	export const npm_package_json: string;
	export const __CFBundleIdentifier: string;
	export const npm_command: string;
	export const PWD: string;
	export const npm_lifecycle_event: string;
	export const npm_package_name: string;
	export const LANG: string;
	export const XPC_FLAGS: string;
	export const VSCODE_GIT_ASKPASS_EXTRA_ARGS: string;
	export const npm_package_version: string;
	export const XPC_SERVICE_NAME: string;
	export const VSCODE_INJECTION: string;
	export const HOME: string;
	export const SHLVL: string;
	export const VSCODE_GIT_ASKPASS_MAIN: string;
	export const LOGNAME: string;
	export const npm_lifecycle_script: string;
	export const VSCODE_GIT_IPC_HANDLE: string;
	export const BUN_INSTALL: string;
	export const npm_config_user_agent: string;
	export const GIT_ASKPASS: string;
	export const VSCODE_GIT_ASKPASS_NODE: string;
	export const Q_NEW_SESSION: string;
	export const OSLogRateLimit: string;
	export const npm_node_execpath: string;
	export const _tide_location_color: string;
	export const COLORTERM: string;
	export const _: string;
	export const NODE_ENV: string;
}

/**
 * Similar to [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private), except that it only includes environment variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`), and can therefore safely be exposed to client-side code.
 * 
 * Values are replaced statically at build time.
 * 
 * ```ts
 * import { PUBLIC_BASE_URL } from '$env/static/public';
 * ```
 */
declare module '$env/static/public' {
	
}

/**
 * This module provides access to runtime environment variables, as defined by the platform you're running on. For example if you're using [`adapter-node`](https://github.com/sveltejs/kit/tree/main/packages/adapter-node) (or running [`vite preview`](https://svelte.dev/docs/kit/cli)), this is equivalent to `process.env`. This module only includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured).
 * 
 * This module cannot be imported into client-side code.
 * 
 * ```ts
 * import { env } from '$env/dynamic/private';
 * console.log(env.DEPLOYMENT_SPECIFIC_VARIABLE);
 * ```
 * 
 * > [!NOTE] In `dev`, `$env/dynamic` always includes environment variables from `.env`. In `prod`, this behavior will depend on your adapter.
 */
declare module '$env/dynamic/private' {
	export const env: {
		PUID: string;
		PGID: string;
		UMASK: string;
		CONTAINER_PREFIX: string;
		CONFIG_PATH: string;
		DATA_PATH: string;
		TZ: string;
		RESTART_POLICY: string;
		NETWORK_MODE: string;
		HOST: string;
		BASE_DOMAIN: string;
		TAG: string;
		DOT_TCP_PORT: string;
		DOT_UDP_PORT: string;
		DOQ_PORT: string;
		DTLS_PORT: string;
		METRICS_OTLP: string;
		TRACING_OTLP: string;
		INSECURE_OTLP: string;
		CF_ENABLED: string;
		CLOUDFLARE_DNS_API_TOKEN: string;
		CF_ZONE_ID: string;
		CF_TUNNEL_ID: string;
		CF_ACCOUNT_ID: string;
		CF_TUNNEL_SECRET: string;
		CF_API_EMAIL: string;
		ACME_CA_SERVER: string;
		AUTO_UPDATE: string;
		GOTIFY_URL: string;
		GOFITY_TOKEN: string;
		TERM_PROGRAM: string;
		NODE: string;
		SHELL: string;
		TERM: string;
		TMPDIR: string;
		VSCODE_PYTHON_AUTOACTIVATE_GUARD: string;
		TERM_PROGRAM_VERSION: string;
		ORIGINAL_XDG_CURRENT_DESKTOP: string;
		_tide_color_separator_same_color: string;
		FIG_NEW_SESSION: string;
		MallocNanoZone: string;
		npm_config_local_prefix: string;
		USER: string;
		COMMAND_MODE: string;
		SSH_AUTH_SOCK: string;
		__CF_USER_TEXT_ENCODING: string;
		npm_execpath: string;
		PATH: string;
		npm_package_json: string;
		__CFBundleIdentifier: string;
		npm_command: string;
		PWD: string;
		npm_lifecycle_event: string;
		npm_package_name: string;
		LANG: string;
		XPC_FLAGS: string;
		VSCODE_GIT_ASKPASS_EXTRA_ARGS: string;
		npm_package_version: string;
		XPC_SERVICE_NAME: string;
		VSCODE_INJECTION: string;
		HOME: string;
		SHLVL: string;
		VSCODE_GIT_ASKPASS_MAIN: string;
		LOGNAME: string;
		npm_lifecycle_script: string;
		VSCODE_GIT_IPC_HANDLE: string;
		BUN_INSTALL: string;
		npm_config_user_agent: string;
		GIT_ASKPASS: string;
		VSCODE_GIT_ASKPASS_NODE: string;
		Q_NEW_SESSION: string;
		OSLogRateLimit: string;
		npm_node_execpath: string;
		_tide_location_color: string;
		COLORTERM: string;
		_: string;
		NODE_ENV: string;
		[key: `PUBLIC_${string}`]: undefined;
		[key: `${string}`]: string | undefined;
	}
}

/**
 * Similar to [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), but only includes variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`), and can therefore safely be exposed to client-side code.
 * 
 * Note that public dynamic environment variables must all be sent from the server to the client, causing larger network requests — when possible, use `$env/static/public` instead.
 * 
 * ```ts
 * import { env } from '$env/dynamic/public';
 * console.log(env.PUBLIC_DEPLOYMENT_SPECIFIC_VARIABLE);
 * ```
 */
declare module '$env/dynamic/public' {
	export const env: {
		[key: `PUBLIC_${string}`]: string | undefined;
	}
}
