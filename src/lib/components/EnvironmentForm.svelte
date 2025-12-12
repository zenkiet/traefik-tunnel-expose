<script lang="ts">
	import { enhance } from '$app/forms';
	import type { Summary } from '$lib/types';
	import type { SubmitFunction } from '@sveltejs/kit';

	let { summary, handleEnvSubmit } = $props<{
		summary: Summary;
		handleEnvSubmit: SubmitFunction;
	}>();
</script>

<div class="glass rounded-2xl p-4">
	<form method="post" use:enhance={handleEnvSubmit} class="space-y-3">
		<div class="flex flex-wrap items-center justify-between gap-3">
			<div>
				<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">Environment</p>
				<h3 class="text-base font-semibold text-slate-50 md:text-lg">Quick edit</h3>
			</div>

			<button class="soft-button" type="submit" disabled={summary.envSaving}>
				<span>Save</span>
			</button>
		</div>

		<div class="grid gap-4 md:grid-cols-2">
			<label class="space-y-1 flex-col flex text-sm text-slate-200">
				<span class="text-xs font-medium tracking-wide text-slate-300">BASE_DOMAIN</span>
				<input
					class="input"
					name="BASE_DOMAIN"
					bind:value={summary.baseDomain}
					placeholder="zenkiet.com"
				/>
			</label>

			<label class="space-y-1 flex-col flex text-sm text-slate-200">
				<span class="text-xs font-medium tracking-wide text-slate-300">HOST</span>
				<input class="input" name="HOST" bind:value={summary.host} placeholder="127.0.0.1" />
			</label>

			<label class="space-y-1 flex-col flex text-sm text-slate-200">
				<span class="text-xs font-medium tracking-wide text-slate-300">CF_TUNNEL_ID</span>
				<input
					class="input"
					name="CF_TUNNEL_ID"
					bind:value={summary.cloudflare.tunnelId}
					placeholder="your-tunnel-id"
				/>
			</label>

			<div class="col-span-full flex flex-col gap-3 md:flex-row mt-1">
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
						class={`relative inline-flex h-5 w-10 items-center rounded-full transition-all duration-200 cursor-pointer ${
							summary.autoUpdate ? 'bg-emerald-500' : 'bg-slate-600'
						}`}
						onclick={() => (summary.autoUpdate = !summary.autoUpdate)}
					>
						<span
							class={`inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-all duration-200 ${
								summary.autoUpdate ? 'translate-x-5' : 'translate-x-0'
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
						class={`relative inline-flex h-5 w-10 items-center rounded-full transition-all duration-200 ${
							summary.cloudflare.enabled ? 'bg-emerald-500' : 'bg-slate-600'
						}`}
						onclick={() => (summary.cloudflare.enabled = !summary.cloudflare.enabled)}
					>
						<span
							class={`inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-all duration-200 ${
								summary.cloudflare.enabled ? 'translate-x-5' : 'translate-x-0'
							}`}
						></span>
					</button>

					<input type="hidden" name="CF_ENABLED" value={summary.cloudflare.enabled} />
				</div>
			</div>
		</div>
	</form>
</div>
