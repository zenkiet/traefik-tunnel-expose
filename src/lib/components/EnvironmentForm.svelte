<script lang="ts">
	import { enhance } from '$app/forms';
	import type { Summary } from '$lib/types';
	import type { SubmitFunction } from '@sveltejs/kit';
	import Button from './ui/button.svelte';

	let { summary, handleEnvSubmit } = $props<{
		summary: Summary;
		handleEnvSubmit: SubmitFunction;
	}>();
</script>

<div class="panel">
	<form method="post" use:enhance={handleEnvSubmit} class="space-y-3">
		<div class="flex flex-wrap items-center justify-between gap-3">
			<div>
				<p class="section-label">Environment</p>
				<h3 class="section-title">Quick edit</h3>
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

			<label class="flex flex-col gap-1 text-sm col-span-full">
				<span class="text-xs font-medium tracking-wide text-muted">CF_TUNNEL_ID</span>
				<input
					class="input"
					name="CF_TUNNEL_ID"
					bind:value={summary.cloudflare.tunnelId}
					placeholder="your-tunnel-id"
				/>
			</label>

			<div class="col-span-full mt-1 grid gap-3 md:grid-cols-2">
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

{#snippet Toggle({
	name,
	label,
	desc,
	get,
	set
}: {
	name: string;
	label: string;
	desc?: string;
	get: () => boolean;
	set: (v: boolean) => void;
})}
	<div class="flex items-center justify-between rounded-xl border border-token bg-card px-3 py-2 text-sm">
		<div class="flex flex-col">
			<span class="text-xs font-medium tracking-wide">{label}</span>
			{#if desc}
				<span class="line-clamp-1 text-[11px] text-hint">{desc}</span>
			{/if}
		</div>

		<button
			type="button"
			aria-label={`Toggle ${name}`}
			aria-pressed={get()}
			class="toggle-track {get() ? '' : '!bg-[var(--border-hover)]'}"
			onclick={() => set(!get())}
		>
			<span class="toggle-thumb {get() ? 'translate-x-5' : 'translate-x-0'}"></span>
		</button>

		<input type="hidden" {name} value={get() ? 'true' : 'false'} />
	</div>
{/snippet}
