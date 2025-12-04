<script lang="ts">
  import { onDestroy, onMount } from 'svelte';
  import YAML from 'yaml';
  import ServiceSidebar from '$lib/components/ServiceSidebar.svelte';
  import EnvironmentForm from '$lib/components/EnvironmentForm.svelte';
  import EditorPanel from '$lib/components/EditorPanel.svelte';
  import NewServiceModal from '$lib/components/dialogs/NewServiceModal.svelte';
  import DeleteConfirmModal from '$lib/components/dialogs/DeleteConfirmModal.svelte';
  import type { ConfigFile, Summary } from '$lib/types';
  import type { PageData } from './$types';
  import type { SubmitFunction } from '@sveltejs/kit';

  const { data }: { data: PageData } = $props();

  // Core data
  let summary: Summary = $state<Summary>({} as Summary);
  let files = $state<ConfigFile[]>([]);
  $effect(() => {
    files = data.files ?? [];
    summary = data.summary ?? {};
  });

  // File editor state
  let selectedId = $state('');
  let fileContent = $state('');
  let fileLoading = $state(false);
  let fileSaving = $state(false);
  let fileError = $state('');
  let fileMessage = $state('');
  let isValidYaml = $state(true);
  let validationMessage = $state('Ready');

  // Environment state
  let envSaving = $state(false);
  let envStatus = $state('');

  // UI state
  let search = $state('');
  let showNewModal = $state(false);
  let modalFileName = $state('');
  let modalServiceName = $state('');
  let newServiceError = $state('');
  let showDeleteModal = $state(false);
  let deleteTarget = $state<ConfigFile | null>(null);

  // Timers for cleanup
  let validateTimer: ReturnType<typeof setTimeout> | null = null;
  let messageTimer: ReturnType<typeof setTimeout> | null = null;
  let envMessageTimer: ReturnType<typeof setTimeout> | null = null;

  // Derived values (memoized)
  const services = $derived(files.filter(f => f.category === 'service'));
  const selectedEntry = $derived(files.find(f => f.id === selectedId) ?? null) ;
  // const configDir = $derived((envValues.CONFIG_DIR || 'conf.d').replace(/\/+$/, ''));

  // Initialize on mount
  onMount(() => {
    const first = services.find(f => f.exists) ?? services[0];
    if (first?.id) loadFile(first.id);
  });

  // Cleanup all timers on unmount
  onDestroy(() => {
    clearAllTimers();
  });

  function clearAllTimers() {
    if (validateTimer) clearTimeout(validateTimer);
    if (messageTimer) clearTimeout(messageTimer);
    if (envMessageTimer) clearTimeout(envMessageTimer);
    validateTimer = null;
    messageTimer = null;
    envMessageTimer = null;
  }

  // Debounced YAML validation
  function validateYaml(content: string) {
    try {
      YAML.parse(content || '{}');
      isValidYaml = true;
      validationMessage = 'YAML valid';
    } catch {
      isValidYaml = false;
      validationMessage = 'Invalid YAML';
    }
  }

  function scheduleValidation(content: string) {
    if (validateTimer) clearTimeout(validateTimer);
    validateTimer = setTimeout(() => {
      validateYaml(content);
      validateTimer = null;
    }, 250);
  }

  // Auto-clear messages
  function showTemporaryMessage(setter: (msg: string) => void, message: string, duration = 2400) {
    setter(message);
    const timer = setTimeout(() => setter(''), duration);
    return timer;
  }

  // API calls
  async function refreshFiles() {
    try {
      const res = await fetch('/api/files');
      if (res.ok) {
        const payload = await res.json();
        files = payload.files ?? files;
      }
    } catch (err) {
      console.error('Failed to refresh files:', err);
    }
  }

  async function loadFile(id: string) {
    // Clear validation timer
    if (validateTimer) {
      clearTimeout(validateTimer);
      validateTimer = null;
    }

    // Remove non-existent selected entry
    if (selectedEntry && !selectedEntry.exists) {
      files = files.filter(f => f.id !== selectedEntry.id);
    }

    if (!id) return;

    fileLoading = true;
    fileError = '';
    selectedId = id;

    const entry = files.find(f => f.id === id);

    // Handle new (non-existent) files
    if (entry && !entry.exists) {
      fileLoading = false;
      validateYaml(fileContent);
      return;
    }

    try {
      const res = await fetch(`/api/files/${encodeURIComponent(id)}`);
      if (!res.ok) {
        throw new Error((await res.text()) || 'Unable to load file');
      }

      const payload = await res.json();
      fileContent = payload.content ?? '';
      fileMessage = '';
      validateYaml(fileContent);
    } catch (err) {
      fileError = err instanceof Error ? err.message : 'Failed to load file';
      fileContent = '';
    } finally {
      fileLoading = false;
    }
  }

  async function saveFile(e?: Event) {
    e?.preventDefault();
    if (!selectedId) return;

    fileSaving = true;
    fileMessage = '';
    fileError = '';

    try {
      const res = await fetch(`/api/files/${encodeURIComponent(selectedId)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content: fileContent })
      });

      if (!res.ok) {
        throw new Error((await res.text()) || 'Unable to save file');
      }

      await refreshFiles();
      if (messageTimer) clearTimeout(messageTimer);
      messageTimer = showTemporaryMessage((msg) => fileMessage = msg, 'Saved');
    } catch (err) {
      fileError = err instanceof Error ? err.message : 'Failed to save file';
    } finally {
      fileSaving = false;
    }
  }

  const handleEnvSubmit: SubmitFunction = async ({ cancel, formData }) => {
    cancel();
    envSaving = true;
    envStatus = '';

    const payload = Object.fromEntries(
      ['BASE_DOMAIN', 'HOST', 'CF_TUNNEL_ID', 'AUTO_UPDATE', 'CF_ENABLED'].map(key => [
        key,
        String(formData.get(key) ?? '').trim()
      ])
    );

    try {
      const res = await fetch('/api/env', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (!res.ok) throw new Error('Could not save .env');

      const body = await res.json();
      // envValues = body.env?.values ?? envValues;

      await refreshFiles();
      if (envMessageTimer) clearTimeout(envMessageTimer);
      envMessageTimer = showTemporaryMessage((msg) => envStatus = msg, 'Saved .env');
    } catch (err) {
      envStatus = err instanceof Error ? err.message : 'Failed to save .env';
    } finally {
      envSaving = false;
    }
  };

  // Utility functions
  const slugify = (name: string): string =>
    name
      .toLowerCase()
      .replace(/[^a-z0-9-]+/g, '-')
      .replace(/-{2,}/g, '-')
      .replace(/^-+|-+$/g, '');

  const serviceTemplate = (service: string, domain: string): string => {
    const svc = service || 'service';
    const dom = domain || 'example.com';

    return `http:
  routers:
    ${svc}:
      rule: "Host(\`${svc}.${dom}\`)"
      service: "${svc}-svc"
      entryPoints:
        - websecure
      tls:
        certResolver: cloudflare
      middlewares:
        - default-headers

  services:
    ${svc}-svc:
      loadBalancer:
        servers:
          - url: "http://${svc}:80"
        passHostHeader: true

  middlewares:
    default-headers:
      headers:
        sslRedirect: true
        frameDeny: true
        browserXssFilter: true
`;
  };

  // Service management
  function createService(name: string, fileName?: string) {
    const slug = slugify(name.replace(/\.(yml|yaml)$/i, ''));
    if (!slug) {
      newServiceError = 'Invalid service name';
      return;
    }

    const finalFile = fileName?.match(/\.(yml|yaml)$/i) ? fileName : `${slug}.yml`;
    const id = `service/${finalFile}`;

    if (files.find(f => f.id === id)) {
      newServiceError = 'Service already exists';
      return;
    }

    const entry: ConfigFile = {
      id,
      label: finalFile,
      filePath: `${summary.path.services}/${finalFile}`,
      category: 'service',
      exists: false
    };

    files = [...files, entry];
    selectedId = id;
    fileContent = serviceTemplate(slug, summary.baseDomain);
    newServiceError = '';
    fileMessage = 'Template ready — edit & save to write it';
    validateYaml(fileContent);
  }

  // Modal handlers
  function openNewModal() {
    showNewModal = true;
    modalFileName = '';
    modalServiceName = '';
    newServiceError = '';
  }

  function confirmCreateService() {
    const name = (modalServiceName || modalFileName).trim();
    if (!slugify(name)) {
      newServiceError = 'Provide a valid service name';
      return;
    }
    createService(name, modalFileName?.trim() || undefined);
    showNewModal = false;
  }

  function promptDelete(file: ConfigFile) {
    deleteTarget = file;
    showDeleteModal = true;
  }

  function cancelDelete() {
    showDeleteModal = false;
    deleteTarget = null;
  }

  async function confirmDeleteFile() {
    if (!deleteTarget) return;

    // Handle non-existent files (templates)
    if (!deleteTarget.exists) {
      files = files.filter(f => f.id !== deleteTarget?.id);
      if (selectedId === deleteTarget?.id) {
        const next = files.find(f => f.exists) ?? files[0];
        selectedId = next?.id ?? '';
        if (next?.id) await loadFile(next.id);
        else fileContent = '';
      }
      cancelDelete();
      return;
    }

    try {
      const res = await fetch(`/api/files/${encodeURIComponent(deleteTarget.id)}`, {
        method: 'DELETE'
      });

      if (!res.ok) {
        throw new Error((await res.text()) || 'Unable to delete file');
      }

      files = files.filter(f => f.id !== deleteTarget?.id);

      if (selectedId === deleteTarget.id) {
        const next = files.find(f => f.exists) ?? files[0];
        selectedId = next?.id ?? '';
        if (next?.id) await loadFile(next.id);
        else fileContent = '';
      }
    } catch (err) {
      fileError = err instanceof Error ? err.message : 'Failed to delete file';
    } finally {
      cancelDelete();
    }
  }

  function handleContentChange(content: string) {
    fileContent = content;
    scheduleValidation(content);
  }
</script>

<section class="mx-auto max-w-full px-4 py-6 lg:py-8 grid grid-cols-1 gap-5 lg:grid-cols-2">
  <ServiceSidebar
    {services}
    {selectedId}
    {search}
    onSelect={loadFile}
    onCreate={openNewModal}
  />

  <div class="flex flex-col gap-4">
    <EnvironmentForm
      {summary}
      {handleEnvSubmit}
    />

    <EditorPanel
      {selectedEntry}
      {fileContent}
      {fileSaving}
      {fileLoading}
      {isValidYaml}
      {validationMessage}
      {fileError}
      {fileMessage}
      onSave={saveFile}
      onDelete={promptDelete}
      onContentChange={handleContentChange}
    />
  </div>
</section>

<NewServiceModal
  open={showNewModal}
  serviceName={modalServiceName}
  fileName={modalFileName}
  errorMessage={newServiceError}
  onCancel={() => showNewModal = false}
  onConfirm={confirmCreateService}
/>

<DeleteConfirmModal
  open={showDeleteModal}
  target={deleteTarget}
  onCancel={cancelDelete}
  onConfirm={confirmDeleteFile}
/>