<script lang="ts">
	import { type VariantProps, tv, cn } from 'tailwind-variants';
	import type { HTMLButtonAttributes } from 'svelte/elements';

	const buttonVariants = tv({
		base: [
			'inline-flex items-center justify-center gap-2 whitespace-nowrap',
			'select-none font-semibold text-sm',
			'rounded-xl',
			'transition duration-150 cursor-pointer',
			'disabled:pointer-events-none disabled:opacity-50 disabled:cursor-not-allowed',
			'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-(--accent) focus-visible:ring-offset-1'
		].join(' '),
		variants: {
			variant: {
				default: 'bg-glass border border-token',
				destructive:
					'border bg-[var(--destructive-muted)] border-[color-mix(in_oklab,var(--destructive)_30%,transparent)] text-[var(--destructive)] hover:bg-[color-mix(in_oklab,var(--destructive-muted)_200%,transparent)]',
				outline:
					'border border-token bg-transparent hover:bg-[var(--card-hover)] hover:border-[var(--border-hover)]',
				secondary: 'bg-[var(--surface)] border border-token hover:bg-[var(--card-hover)]',
				ghost: 'hover:bg-[var(--card-hover)]',
				link: 'text-primary underline-offset-4 hover:underline'
			},
			size: {
				default: 'px-3 py-2',
				sm: 'rounded-md px-3',
				lg: 'rounded-md px-8',
				icon: 'h-9 w-9 p-0 rounded-xl'
			}
		},
		defaultVariants: {
			variant: 'default',
			size: 'default'
		}
	});

	type ButtonProps = HTMLButtonAttributes &
		VariantProps<typeof buttonVariants> & {
			ref?: HTMLButtonElement;
		};

	let {
		class: className,
		variant,
		size,
		children,
		ref = $bindable<HTMLButtonElement>(),
		...rest
	}: ButtonProps = $props();
</script>

<button bind:this={ref} class={cn(buttonVariants({ variant, size }), className)} {...rest}>
	{@render children?.()}
</button>
