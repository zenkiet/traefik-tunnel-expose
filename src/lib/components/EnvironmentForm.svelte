<script lang="ts">
  import { enhance } from '$app/forms';
	import type { Summary } from '$lib/types';
  import type { SubmitFunction } from '@sveltejs/kit';

  let {
    summary,
    handleEnvSubmit
  } = $props<{
    summary: Summary
    handleEnvSubmit: SubmitFunction;
  }>();
</script>

<div class="glass rounded-2xl p-4">
	<div class="flex flex-wrap items-center justify-between gap-3">
		<div>
			<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">Environment</p>
			<h3 class="text-base font-semibold text-slate-50 md:text-lg">Quick edit</h3>
		</div>
		{#if summary?.envStatus}
			<span
				class="pill animate-fade-in rounded-full bg-emerald-500/15 px-3 py-1 text-xs font-medium text-emerald-200 ring-1 ring-emerald-400/40"
				>{summary.envStatus}</span
			>
		{/if}
	</div>

	<form
		class="mt-3 grid gap-3 md:grid-cols-2"
		method="post"
		action="/api/env"
		use:enhance={handleEnvSubmit}
	>
		<label class="space-y-1 flex-col flex text-sm text-slate-200">
			<span class="text-xs font-medium tracking-wide text-slate-300">BASE_DOMAIN</span>
			<input class="input" name="BASE_DOMAIN" bind:value={summary.baseDomain} placeholder="zenkiet.dev" />
		</label>
		<label class="space-y-1 flex-col flex text-sm text-slate-200">
			<span class="text-xs font-medium tracking-wide text-slate-300">HOST</span>
			<input class="input" name="HOST" bind:value={summary.host} placeholder="127.0.0.1" />
		</label>
		<label class="space-y-1 flex-col flex text-sm text-slate-200">
			<span class="text-xs font-medium tracking-wide text-slate-300">CF_TUNNEL_ID</span>
			<input class="input" name="CF_TUNNEL_ID" bind:value={summary.tunnelId} placeholder="your-tunnel-id" />
		</label>

		<div class="col-span-full flex flex-col gap-3 md:flex-row">
			<div
				class="flex flex-1 items-center justify-between rounded-xl border border-slate-700/70 bg-slate-900/60 px-3 py-2 text-sm text-slate-200"
			>
				<div class="flex flex-col">
					<span class="text-xs font-medium tracking-wide text-slate-300">AUTO_UPDATE</span>
					<span class="text-[11px] text-slate-500"
						>Automatically update cloudflared & traefik every day</span
					>
				</div>

				<button
					type="button"
					aria-label="Toggle AUTO_UPDATE"
					aria-pressed={summary.autoUpdate === 'true'}
					class={`relative inline-flex h-5 w-10 items-center rounded-full transition-all duration-200 ${
						summary.autoUpdate === 'true' ? 'bg-emerald-500' : 'bg-slate-600'
					}`}
					onclick={() => (summary.autoUpdate = summary.autoUpdate === 'true' ? 'false' : 'true')}
				>
					<span
						class={`inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-all duration-200 ${
							summary.autoUpdate === 'true' ? 'translate-x-5' : 'translate-x-0'
						}`}
					></span>
				</button>

				<input type="hidden" name="AUTO_UPDATE" value={summary.autoUpdate} />
			</div>

			<div
				class="flex flex-1 items-center justify-between rounded-xl border border-slate-700/70 bg-slate-900/60 px-3 py-2 text-sm text-slate-200"
			>
				<div class="flex flex-col">
					<span class="text-xs font-medium tracking-wide text-slate-300">CF_ENABLED</span>
					<span class="text-[11px] text-slate-500">Turn on/off cloudflare tunnel</span>
				</div>

				<button
					type="button"
					aria-label="Toggle CF_ENABLED"
					aria-pressed={summary.cfEnabled === 'true'}
					class={`relative inline-flex h-5 w-10 items-center rounded-full transition-all duration-200 ${
						summary.cfEnabled === 'true' ? 'bg-emerald-500' : 'bg-slate-600'
					}`}
					onclick={() => (summary.cfEnabled = summary.cfEnabled === 'true' ? 'false' : 'true')}
				>
					<span
						class={`inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-all duration-200 ${
							summary.cfEnabled === 'true' ? 'translate-x-5' : 'translate-x-0'
						}`}
					></span>
				</button>

				<input type="hidden" name="CF_ENABLED" value={summary.cfEnabled} />
			</div>
		</div>

		<div class="col-span-full mt-1 flex flex-wrap items-center gap-3">
			<button class="soft-button" type="submit" disabled={summary.envSaving}>
				<span>Save</span>
			</button>
			{#if summary.envFilePath}
				<span class="text-xs text-slate-400">Path: {summary.envFilePath}</span>
			{/if}
		</div>
	</form>
</div>
