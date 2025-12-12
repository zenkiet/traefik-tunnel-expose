export const formatDate = (
	date: Date | string,
	locale = 'en-US',
	options: Intl.DateTimeFormatOptions = {
		year: 'numeric',
		month: 'short',
		day: 'numeric',
		hour: '2-digit',
		minute: '2-digit'
	}
) => {
	const dt = typeof date === 'string' ? new Date(date) : date;
	return new Intl.DateTimeFormat(locale, options).format(dt);
};

export const formatRelativeDate = (date: Date | string, locale = 'en-US') => {
	const dt = typeof date === 'string' ? new Date(date) : date;
	const now = new Date();
	const diff = now.getTime() - dt.getTime();

	const seconds = Math.floor(diff / 1000);
	const minutes = Math.floor(seconds / 60);
	const hours = Math.floor(minutes / 60);
	const days = Math.floor(hours / 24);

	if (days > 0) {
		return new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(-days, 'day');
	} else if (hours > 0) {
		return new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(-hours, 'hour');
	} else if (minutes > 0) {
		return new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(-minutes, 'minute');
	} else {
		return new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(-seconds, 'second');
	}
};
