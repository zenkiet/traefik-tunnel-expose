<script lang="ts">
	const input = $props<{ isLoading: boolean }>();
</script>

<svg id="upgrade" class="h-6 w-6" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
	<g>
		<path
			class={`fill-none stroke-current stroke-2 transition-opacity duration-200 ${
				input.isLoading ? 'animate-[fadeWave_1.5s_ease-in-out_infinite]' : 'opacity-80'
			}`}
			d="m37.41 14.59-12-12c-.78-.78-2.05-.78-2.83 0l-12 12c-.78.78-.78 2.05 0 2.83s2.05.78 2.83 0l10.59-10.59 10.59 10.59c.39.38.9.58 1.41.58s1.02-.2 1.41-.59c.79-.78.79-2.04 0-2.82z"
		/>
		<path
			class={`fill-none stroke-current stroke-2 transition-opacity duration-200 ${
				input.isLoading ? 'animate-[fadeWave_1.5s_ease-in-out_0.3s_infinite]' : 'opacity-80'
			}`}
			d="m37.41 28.59-12-12c-.78-.78-2.05-.78-2.83 0l-12 12c-.78.78-.78 2.05 0 2.83s2.05.78 2.83 0l10.59-10.59 10.59 10.59c.39.38.9.58 1.41.58s1.02-.2 1.41-.59c.79-.78.79-2.04 0-2.82z"
		/>
		<path
			class={`fill-none stroke-current stroke-2 transition-opacity duration-200 ${
				input.isLoading ? 'animate-[fadeWave_1.5s_ease-in-out_0.6s_infinite]' : 'opacity-80'
			}`}
			d="m37.41 42.59-12-12c-.78-.78-2.05-.78-2.83 0l-12 12c-.78.78-.78 2.05 0 2.83s2.05.78 2.83 0l10.59-10.59 10.59 10.59c.39.38.9.58 1.41.58s1.02-.2 1.41-.59c.79-.78.79-2.04 0-2.82z"
		/>
	</g>
</svg>
