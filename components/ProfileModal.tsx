// components/ProfileModal.tsx
import React, { useEffect, useState } from 'react';
import {
  View, Text, Button, Modal, StyleSheet,
  TextInput, Alert, ActivityIndicator
} from 'react-native';
import * as Linking from 'expo-linking';
import Constants from 'expo-constants';
import { supabase } from '../lib/supabaseClient';

type Props = { visible: boolean; onClose: () => void };

function makeEmailRedirectTo() {
  const host = (Constants as any).expoConfig?.hostUri;
  if (host && typeof host === 'string' && host.includes('exp.direct')) {
    return `exp://${host}/--/reset`;
  }
  return Linking.createURL('reset', { scheme: 'kura' });
}

export default function ProfileModal({ visible, onClose }: Props) {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [email, setEmail] = useState<string>('');
  const [emailConfirmed, setEmailConfirmed] = useState<boolean>(false);
  const [fullName, setFullName] = useState<string>('');

  useEffect(() => {
    if (!visible) return;
    (async () => {
      setLoading(true);
      try {
        const { data: { session } } = await supabase.auth.getSession();
        const u = session?.user;
        const uid = u?.id;
        setEmail(u?.email ?? '');
        const confirmedAt = (u as any)?.email_confirmed_at ?? null;
        setEmailConfirmed(!!confirmedAt);

        if (!uid) { setLoading(false); return; }

        const { data: prof, error } = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', uid)
          .single();

        if (error && (error as any).code !== 'PGRST116') throw error; // pas de ligne = ok
        setFullName(prof?.full_name ?? '');
      } catch (e: any) {
        Alert.alert('Erreur', e?.message ?? 'Impossible de charger le profil.');
      } finally {
        setLoading(false);
      }
    })();
  }, [visible]);

  const saveProfile = async () => {
    try {
      setSaving(true);
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Non connecté');

      const { error } = await supabase
        .from('profiles')
        .upsert({ id: user.id, full_name: fullName }, { onConflict: 'id' });

      if (error) throw error;
      Alert.alert('OK', 'Profil mis à jour.');
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? 'Sauvegarde impossible.');
    } finally {
      setSaving(false);
    }
  };

  const resendConfirmation = async () => {
    if (!email) return;
    try {
      const emailRedirectTo = makeEmailRedirectTo();
      const { error } = await supabase.auth.resend({
        type: 'signup',
        email,
        options: { emailRedirectTo },
      });
      if (error) throw error;
      Alert.alert('Envoyé', "Email de confirmation renvoyé (pense au spam).");
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? "Impossible d'envoyer l'email.");
    }
  };

  const logout = async () => {
    await supabase.auth.signOut();
    onClose();
  };

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <View style={s.wrap}>
        <Text style={s.h1}>Profil</Text>

        {loading ? (
          <View style={s.center}><ActivityIndicator /><Text style={{marginTop:8}}>Chargement…</Text></View>
        ) : (
          <>
            <View style={s.row}>
              <Text style={s.label}>Email</Text>
              <Text style={s.value}>{email || '—'}</Text>
            </View>

            <View style={s.row}>
              <Text style={s.label}>Statut email</Text>
              <Text style={[s.badge, emailConfirmed ? s.badgeOk : s.badgeKo]}>
                {emailConfirmed ? 'Confirmé' : 'Non confirmé'}
              </Text>
            </View>

            {/* 👉 Toujours visible maintenant */}
            <View style={{ marginTop: 8 }}>
              <Button title="Renvoyer l’email de confirmation" onPress={resendConfirmation} />
            </View>

            <View style={s.sep} />

            <Text style={s.h2}>Nom complet</Text>
            <TextInput
              style={s.input}
              placeholder="Ton nom complet"
              value={fullName}
              onChangeText={setFullName}
              autoCapitalize="words"
            />
            <Button title={saving ? '...' : 'Enregistrer'} onPress={saveProfile} disabled={saving} />

            <View style={s.sep} />
            <Button title="Se déconnecter" onPress={logout} color="#b00020" />
          </>
        )}

        <View style={{ height: 16 }} />
        <Button title="Fermer" onPress={onClose} />
      </View>
    </Modal>
  );
}

const s = StyleSheet.create({
  wrap: { flex: 1, padding: 20 },
  h1: { fontSize: 22, fontWeight: '700', marginBottom: 16 },
  h2: { fontSize: 16, fontWeight: '600', marginBottom: 8 },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 },
  label: { fontWeight: '500', color: '#333' },
  value: { color: '#111' },
  badge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 20, overflow: 'hidden' },
  badgeOk: { backgroundColor: '#E6F6EA', color: '#0A7C2F' },
  badgeKo: { backgroundColor: '#FFF1F0', color: '#B00020' },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 8, padding: 10, marginBottom: 10 },
  sep: { height: 16 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});