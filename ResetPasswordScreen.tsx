import React, { useEffect, useState } from 'react';
import { View, Text, TextInput, Button, Alert, StyleSheet, ActivityIndicator } from 'react-native';
import { supabase } from './lib/supabaseClient';

export default function ResetPasswordScreen({ onDone }: { onDone: () => void }) {
  const [pw, setPw] = useState('');
  const [loading, setLoading] = useState(false);
  const [checking, setChecking] = useState(true);
  const [hasSession, setHasSession] = useState<boolean | null>(null);

  // Vérifie qu'une session (créée par setSession dans App.tsx) est bien en place
  useEffect(() => {
    const check = async () => {
      try {
        const { data } = await supabase.auth.getSession();
        setHasSession(!!data.session);
      } catch {
        setHasSession(null);
      } finally {
        setChecking(false);
      }
    };
    check();
  }, []);

  const ensureSessionOrExplain = async () => {
    const { data } = await supabase.auth.getSession();
    if (!data.session) {
      Alert.alert(
        'Erreur',
        "Session de récupération absente. Rouvre le lien reçu par e-mail depuis l'iPhone (app Mail), puis reviens sur cet écran."
      );
      return false;
    }
    return true;
  };

  const handleChange = async () => {
    if (pw.length < 8) {
      Alert.alert('Erreur', '8 caractères minimum 😉');
      return;
    }

    setLoading(true);
    try {
      // Sécurité : on re-vérifie la session juste avant l’appel
      const ok = await ensureSessionOrExplain();
      if (!ok) return;

      const { error } = await supabase.auth.updateUser({ password: pw });
      if (error) throw error;

      Alert.alert(
        'OK',
        'Mot de passe changé. Tu peux te reconnecter.',
        [{ text: 'OK', onPress: onDone }]
      );
    } catch (e: any) {
      // Messages plus clairs (réseau / session / autre)
      const msg =
        e?.message?.includes('Auth session missing')
          ? "Session absente. Rouvre le lien de l’e-mail."
          : e?.message ?? 'Impossible de changer le mot de passe (réseau ?).';
      Alert.alert('Erreur', msg);
    } finally {
      setLoading(false);
    }
  };

  if (checking) {
    return (
      <View style={s.c}>
        <ActivityIndicator />
        <Text style={{ marginTop: 8 }}>Vérification…</Text>
      </View>
    );
  }

  return (
    <View style={s.c}>
      {!hasSession && (
        <Text style={{ color: '#b00', textAlign: 'center', marginBottom: 12 }}>
          Session absente — rouvre le lien reçu par e-mail pour activer l’écran de
          réinitialisation.
        </Text>
      )}

      <Text style={s.t}>Nouveau mot de passe</Text>
      <TextInput
        style={s.i}
        placeholder="********"
        secureTextEntry
        value={pw}
        onChangeText={setPw}
        autoCapitalize="none"
      />
      <Button title={loading ? '...' : 'Valider'} onPress={handleChange} disabled={loading} />
    </View>
  );
}

const s = StyleSheet.create({
  c: { flex: 1, justifyContent: 'center', padding: 20 },
  t: { fontSize: 18, fontWeight: '600', marginBottom: 12, textAlign: 'center' },
  i: { borderWidth: 1, borderColor: '#ccc', padding: 10, borderRadius: 6, marginBottom: 12 },
});