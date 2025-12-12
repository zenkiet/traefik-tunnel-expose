export const getIcon = import.meta.glob('../assets/*.svg', {
	eager: true,
	import: 'default'
}) as Record<string, string>;
