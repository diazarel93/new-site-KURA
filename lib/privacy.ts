// lib/privacy.ts
import { supabase } from './supabaseClient';

export async function recordConsent(scope: string[], version = '1.0.0') {
  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData.user) throw new Error('Non authentifié');

  const { error } = await supabase.from('consents').insert({
    user_id: userData.user.id,
    scope,
    version,
  });

  if (error) throw error;
  return true;
}

export async function requestExport(): Promise<string> {
  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData.user) throw new Error('Non authentifié');

  // Edge Function `export_user` (déployée côté Supabase)
  const { data, error } = await supabase.functions.invoke('export_user', {
    headers: { 'x-user-id': userData.user.id },
  });
  if (error) throw error;

  return (data as { url: string }).url;
}

export async function softDeleteAccount() {
  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData.user) throw new Error('Non authentifié');

  // 1) log DSAR
  await supabase.from('dsar_requests').insert({
    user_id: userData.user.id,
    type: 'delete',
    status: 'received',
  });

  // 2) marquer suppression J0 (purge hard J+30 via cron)
  await supabase.from('users_flags').upsert({
    user_id: userData.user.id,
    to_delete_at: new Date().toISOString(),
  }, { onConflict: 'user_id' });

  // 3) trace (facultatif)
  await supabase.from('audit_logs').insert({
    actor: userData.user.id,
    action: 'USER_SOFT_DELETE',
    target: userData.user.id,
    details: { plannedHardDeleteInDays: 30 },
  });

  return true;
}
