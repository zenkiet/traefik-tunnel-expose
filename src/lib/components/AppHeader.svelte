<script lang="ts">
	import { useApp } from '$lib/state';
	import { THEME } from '$lib/state/app.svelte';

	const app = useApp();
	const isDark = $derived(app.theme === THEME.DARK);
</script>

<header class="glass flex items-center justify-between gap-4 rounded-b-2xl px-4 py-3 sm:px-6">
	<div class="flex items-center gap-3">
		<p class="section-label">Dashboard</p>
	</div>

	<button
		type="button"
		class="toggle-track h-9 w-18 p-0.5 cursor-pointer scale-75"
		aria-label="Toggle theme"
		aria-pressed={isDark}
		onclick={() => app.toggleTheme()}
	>
		<span
			class="toggle-thumb relative z-10 flex size-8 items-center justify-center transition-all duration-300 ease-out translate-x-0"
			class:translate-x-9={isDark}
		>
			{#if isDark}
				<i class="icon-[duotone--moon] size-4 text-sky-400"></i>
			{:else}
				<i class="icon-[duotone--sun-bright] size-4 text-amber-500"></i>
			{/if}
		</span>

		<span
			class="pointer-events-none absolute left-2 text-hint transition-opacity duration-300"
			class:opacity-0={isDark}
			aria-hidden="true"
		>
			<i class="icon-[duotone--sun-bright] size-3.5 text-amber-500"></i>
		</span>

		<span
			class="pointer-events-none absolute right-2 text-hint transition-opacity duration-300"
			class:opacity-0={!isDark}
			aria-hidden="true"
		>
			<i class="icon-[duotone--moon] size-3.5 text-sky-400"></i>
		</span>
	</button>
</header>
