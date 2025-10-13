import { createClient } from '@supabase/supabase-js';

// On lit d'abord EXPO_PUBLIC_*, sinon NEXT_PUBLIC_* (fallback),
// puis on a un dernier fallback en dur pour ne jamais planter en dev.
const supabaseUrl =
  process.env.EXPO_PUBLIC_SUPABASE_URL ??
  process.env.NEXT_PUBLIC_SUPABASE_URL ??
  'https://jcaonerncnhhvzojhdio.supabase.co';

const supabaseAnonKey =
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ??
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ??
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpjYW9uZXJuY25oaHZ6b2poZGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTEwNDAsImV4cCI6MjA3MjM4NzA0MH0.XDYkwMB6ID5yDF7GGxjW5JmmB-uxW9WoGAewasXq4g0';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});