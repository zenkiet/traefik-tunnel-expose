<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.ico';
	import ToastHost from '$lib/components/ToastHost.svelte';
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
	<link
		href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
		rel="stylesheet"
	/>
	<title>Traefik Tunnel Dashboard</title>
	<meta
		name="description"
		content="Manage Traefik + Cloudflare Tunnel configs with a fast Svelte dashboard."
	/>
</svelte:head>

<div class="min-h-screen bg-linear-to-br from-slate-900 via-slate-950 to-slate-900 text-slate-100">
	<ToastHost />
	<slot />
</div>
