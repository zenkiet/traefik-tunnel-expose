<script lang="ts">
	import { cubicOut } from 'svelte/easing';
	import { fly } from 'svelte/transition';
	import { flip } from 'svelte/animate';
	import { type ToastIntent, toast, type ToastMessage } from '$lib/services/toast';

	const theme: Record<
		ToastIntent,
		{ bar: string; iconBg: string; ring: string; progress: string }
	> = {
		success: {
			bar: 'from-emerald-500 to-emerald-500/20',
			iconBg: 'bg-[var(--emerald-muted)] text-[var(--emerald)]',
			ring: 'ring-[color-mix(in_oklab,var(--emerald)_30%,transparent)]',
			progress: 'bg-[var(--emerald)]'
		},
		info: {
			bar: 'from-sky-500 to-sky-500/20',
			iconBg: 'bg-[var(--accent-muted)] text-[var(--accent)]',
			ring: 'ring-[color-mix(in_oklab,var(--accent)_30%,transparent)]',
			progress: 'bg-[var(--accent)]'
		},
		warning: {
			bar: 'from-amber-500 to-amber-500/20',
			iconBg: 'bg-amber-500/15 text-amber-500',
			ring: 'ring-amber-400/20',
			progress: 'bg-amber-500'
		},
		error: {
			bar: 'from-rose-500 to-rose-500/20',
			iconBg: 'bg-[var(--destructive-muted)] text-[var(--destructive)]',
			ring: 'ring-[color-mix(in_oklab,var(--destructive)_30%,transparent)]',
			progress: 'bg-[var(--destructive)]'
		}
	};

	const handleAction = async (item: ToastMessage) => {
		try {
			await item.action?.callback?.();
		} catch (err) {
			console.error('Toast action failed', err);
		}
		if (item.action?.dismiss !== false) {
			toast.dismiss(item.id);
		}
	};
</script>

<div
	class="pointer-events-none fixed inset-0 z-50 flex flex-col items-end gap-3 px-4 py-6 sm:px-6"
>
	{#each $toast as item (item.id)}
		<div
			animate:flip={{ duration: 300 }}
			in:fly={{ x: 32, duration: 200, easing: cubicOut }}
			out:fly={{ x: 28, duration: 180, easing: cubicOut }}
			class="w-full max-w-105"
		>
			<article
				class="toast-base group ring-1 {theme[item.intent].ring}"
				role={item.intent === 'error' ? 'alert' : 'status'}
				aria-live={item.intent === 'error' ? 'assertive' : 'polite'}
			>
				<div class="absolute inset-y-0 left-0 w-1.5 bg-linear-to-b {theme[item.intent].bar}">
				</div>

				<div class="relative flex gap-3 p-4">
					<div
						class="mt-0.5 flex size-11 shrink-0 items-center justify-center rounded-xl border border-token shadow-inner {theme[item.intent].iconBg}"
					>
						{#if item.intent === 'success'}
							<i class="icon-[duotone--badge-check] size-5"></i>
						{:else if item.intent === 'info'}
							<i class="icon-[duotone--circle-info] size-5"></i>
						{:else if item.intent === 'warning'}
							<i class="icon-[duotone--triangle-exclamation] size-5"></i>
						{:else if item.intent === 'error'}
							<i class="icon-[duotone--brake-warning] size-5"></i>
						{/if}
					</div>

					<div class="min-w-0 flex-1 space-y-2">
						<div class="flex items-start gap-3">
							<div class="min-w-0 flex-1">
								<p class="text-sm font-semibold">{item.title}</p>
								{#if item.description}
									<p class="mt-0.5 text-sm text-muted">{item.description}</p>
								{/if}
							</div>

							{#if item.dismissible}
								<button
									class="icon-box size-8 shrink-0 cursor-pointer text-muted transition hover:border-[var(--border-hover)] hover:text-[var(--text)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-(--accent)"
									aria-label="Dismiss notification"
									onclick={() => toast.dismiss(item.id)}
								>
									<i class="icon-[duotone--xmark] size-3.5"></i>
								</button>
							{/if}
						</div>

						{#if item.action}
							<button
								class="inline-flex items-center gap-2 rounded-lg border border-token bg-[var(--surface)] px-3 py-1.5 text-xs font-semibold transition hover:bg-[var(--card-hover)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-(--accent) cursor-pointer"
								onclick={() => handleAction(item)}
							>
								<span>{item.action.label}</span>
								<i class="icon-[duotone--reply-clock] size-3"></i>
							</button>
						{/if}
					</div>
				</div>

				{#if Number.isFinite(item.duration) && item.duration > 0}
					<div
						class="relative mx-4 mb-4 h-1.5 overflow-hidden rounded-full"
						style="background: var(--surface);"
					>
						<span
							class="progress-bar block h-full w-full rounded-full {theme[item.intent].progress}"
							style="animation-duration: {item.duration}ms;"
						></span>
					</div>
				{/if}
			</article>
		</div>
	{/each}
</div>

<style>
	.progress-bar {
		transform-origin: left;
		animation: toast-progress linear forwards;
	}

	:global(.group:hover .progress-bar) {
		animation-play-state: paused;
	}

	@keyframes toast-progress {
		from {
			transform: scaleX(1);
		}
		to {
			transform: scaleX(0);
		}
	}
</style>
