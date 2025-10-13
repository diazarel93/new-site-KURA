import { createClient } from '@supabase/supabase-js';

// ✅ URL du projet (sans /rest/v1)
const supabaseUrl = 'https://jcaonerncnhhvzojhdio.supabase.co';

// ✅ Clé publique (anon)
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpjYW9uZXJuY25oaHZ6b2poZGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTEwNDAsImV4cCI6MjA3MjM4NzA0MH0.XDYkwMB6ID5yDF7GGxjW5JmmB-uxW9WoGAewasXq4g0';

// ✅ Création du client
export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});