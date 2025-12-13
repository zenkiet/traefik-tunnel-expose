<script lang="ts">
	import { enhance } from '$app/forms';
	import type { Summary } from '$lib/types';
	import type { SubmitFunction } from '@sveltejs/kit';
	import Button from './ui/button.svelte';

	let { summary, handleEnvSubmit } = $props<{
		summary: Summary;
		handleEnvSubmit: SubmitFunction;
	}>();

	const boolValue = (v: boolean) => (v ? 'true' : 'false');
</script>

<div class="glass rounded-2xl p-4">
	<form method="post" use:enhance={handleEnvSubmit} class="space-y-3">
		<div class="flex flex-wrap items-center justify-between gap-3">
			<div>
				<p class="text-xs font-medium uppercase tracking-[0.22em] text-muted">Environment</p>
				<h3 class="text-base font-semibold md:text-lg">Quick edit</h3>
			</div>

			<Button type="submit" disabled={summary.envSaving}>Save</Button>
		</div>

		<div class="grid gap-4 md:grid-cols-2">
			<label class="flex flex-col gap-1 text-sm">
				<span class="text-xs font-medium tracking-wide text-muted">BASE_DOMAIN</span>
				<input
					class="input"
					name="BASE_DOMAIN"
					bind:value={summary.baseDomain}
					placeholder="zenkiet.com"
				/>
			</label>

			<label class="flex flex-col gap-1 text-sm">
				<span class="text-xs font-medium tracking-wide text-muted">HOST</span>
				<input class="input" name="HOST" bind:value={summary.host} placeholder="127.0.0.1" />
			</label>

			<label class="flex flex-col gap-1 text-sm">
				<span class="text-xs font-medium tracking-wide text-muted">CF_TUNNEL_ID</span>
				<input
					class="input"
					name="CF_TUNNEL_ID"
					bind:value={summary.cloudflare.tunnelId}
					placeholder="your-tunnel-id"
				/>
			</label>

			<div class="col-span-full mt-1 flex flex-col gap-3 md:flex-row">
				{@render Toggle({
					name: 'AUTO_UPDATE',
					label: 'AUTO_UPDATE',
					desc: 'Automatically update cloudflared & traefik every day',
					get: () => summary.autoUpdate,
					set: (v) => (summary.autoUpdate = v)
				})}

				{@render Toggle({
					name: 'CF_ENABLED',
					label: 'CF_ENABLED',
					desc: 'Turn on/off cloudflare tunnel',
					get: () => summary.cloudflare.enabled,
					set: (v) => (summary.cloudflare.enabled = v)
				})}
			</div>
		</div>
	</form>
</div>

{#snippet Toggle({ name, label, desc, get, set }: {
	name: string;
	label: string;
	desc?: string;
	get: () => boolean;
	set: (v: boolean) => void;
})}
	<div
		class="flex flex-1 items-center justify-between rounded-xl border px-3 py-2 text-sm
	 bg-card"
	>
		<div class="flex flex-col">
			<span class="text-xs font-medium tracking-wide text-muted">{label}</span>
			{#if desc}
				<span class="text-[11px] text-muted opacity-70">{desc}</span>
			{/if}
		</div>

		<button
			type="button"
			aria-label={`Toggle ${name}`}
			aria-pressed={get()}
			class="relative inline-flex h-5 w-10 items-center rounded-full transition-colors duration-200
				ring-1 ring-black/5 dark:ring-white/10"
			class:bg-emerald-500={get()}
			onclick={() => set(!get())}
		>
			<span
				class="inline-block h-5 w-5 rounded-full bg-white shadow-md transition-transform duration-200
					dark:bg-slate-900"
				class:translate-x-5={get()}
				class:translate-x-0={!get()}
			></span>
		</button>

		<input type="hidden" {name} value={boolValue(get())} />
	</div>
{/snippet}
