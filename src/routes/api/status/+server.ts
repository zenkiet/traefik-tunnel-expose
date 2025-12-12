import { existFile } from '$lib/server/files';
import { json } from '@sveltejs/kit';

export const GET = async () => {
	const traefik = await existFile('/usr/local/bin/traefik');
	const cloudflared = await existFile('/usr/local/bin/cloudflared');

	const data = {
		traefik,
		cloudflared
	};

	return json({ data });
};
