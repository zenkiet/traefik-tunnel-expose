<script lang="ts">
	import { useApp } from '$lib/state';
	import { THEME } from '$lib/state/app.svelte';

	const app = useApp();
	const isDark = $derived(app.theme === THEME.DARK);
</script>

<header class="glass mb-4 flex items-center justify-between gap-4 rounded-b-2xl px-4 py-3 sm:px-6">
	<div class="flex items-center gap-3 sm:gap-4">
		<div
			class="relative grid h-11 w-11 place-items-center overflow-hidden rounded-xl text-white ring-1 ring-white/40
			bg-linear-to-br from-indigo-500/85 via-sky-500/85 to-emerald-400/80"
		>
			<span class="absolute inset-0 bg-white/10 blur-xl"></span>
			<span class="relative text-lg font-semibold leading-none drop-shadow">TT</span>
		</div>

		<div class="leading-tight">
			<p class="text-[11px] font-semibold uppercase tracking-[0.18em] text-(--muted)">Dashboard</p>
			<h1 class="text-lg font-semibold text-(--text) sm:text-xl">Traefik Tunnel Expose</h1>
		</div>
	</div>

	<button
		type="button"
		class="group relative flex h-9 w-18 items-center rounded-full p-0.5 shadow-inner transition-colors
			bg-card ring-1 ring-black/5 hover:ring-(--accent)/50
			focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-(--accent) focus-visible:ring-offset-2 dark:ring-white/10"
		aria-label="Toggle theme"
		aria-pressed={isDark}
		onclick={() => app.toggleTheme()}
	>
		<span
			class="relative z-10 flex h-8 w-8 items-center justify-center rounded-full shadow-md transition-all duration-300 ease-out
				bg-white dark:bg-slate-800 translate-x-0"
			class:translate-x-9={isDark}
		>
			{#if isDark}
				<svg
					class="h-4 w-4 text-sky-400 transition-transform duration-300 group-hover:scale-110"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				>
					<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 1 0 9.8 9.8Z" />
				</svg>
			{:else}
				<svg
					class="h-4 w-4 text-amber-500 transition-transform duration-300 group-hover:scale-110 group-hover:rotate-45"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				>
					<circle cx="12" cy="12" r="4" />
					<path
						d="M12 2v2m0 16v2m10-10h-2M4 12H2m14.5-7.5-1.4 1.4M8.9 15.1l-1.4 1.4m12 0-1.4-1.4M8.9 8.9 7.5 7.5"
					/>
				</svg>
			{/if}
		</span>

		<span
			class="pointer-events-none absolute left-2 opacity-40 transition-opacity duration-300"
			class:opacity-0={isDark}
			aria-hidden="true"
		>
			<svg class="h-3.5 w-3.5 text-amber-500" viewBox="0 0 24 24" fill="currentColor"
				><circle cx="12" cy="12" r="4" /></svg
			>
		</span>

		<span
			class="pointer-events-none absolute right-2 opacity-40 transition-opacity duration-300"
			class:opacity-0={!isDark}
			aria-hidden="true"
		>
			<svg class="h-3.5 w-3.5 text-sky-400" viewBox="0 0 24 24" fill="currentColor"
				><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 1 0 9.8 9.8Z" /></svg
			>
		</span>
	</button>
</header>
