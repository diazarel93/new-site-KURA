// App.tsx
import React, { useEffect, useState } from 'react';
import { View, TextInput, Button, StyleSheet, Alert, ActivityIndicator, Modal, Pressable } from 'react-native';
import * as Linking from 'expo-linking';
import Constants from 'expo-constants';
import { supabase } from './lib/supabaseClient';
import ResetPasswordScreen from './ResetPasswordScreen';
import PrivacyScreen from './screens/PrivacyScreen';
import ConsentBanner from './components/ConsentBanner';
import ProfileModal from './components/ProfileModal';
import { useTheme } from './src/theme';
import { ThemedView, ThemedText } from './components/Themed';

type SupabaseUser = { email: string } | null;

function makeRedirectTo() {
  const host = (Constants as any).expoConfig?.hostUri;
  if (host && typeof host === 'string' && host.includes('exp.direct')) {
    return `exp://${host}/--/reset`;
  }
  return Linking.createURL('reset', { scheme: 'kura' });
}

export default function App() {
  const { colors } = useTheme();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [user, setUser] = useState<SupabaseUser>(null);
  const [loading, setLoading] = useState(false);
  const [showReset, setShowReset] = useState(false);
  const [showPrivacy, setShowPrivacy] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [showCreatePlayer, setShowCreatePlayer] = useState(false);
  const [bootLoading, setBootLoading] = useState(true);

  // --- deep links (reset) ---
  useEffect(() => {
    const handleUrl = async (url?: string | null) => {
      if (!url) return;
      const hash = url.includes('#') ? url.split('#')[1] : '';
      const params = new URLSearchParams(hash);
      const type = params.get('type');
      const access_token = params.get('access_token') ?? '';
      const refresh_token = params.get('refresh_token') ?? '';
      if (type === 'recovery' && access_token && refresh_token) {
        try {
          await supabase.auth.setSession({ access_token, refresh_token });
          setShowReset(true);
        } catch (e: any) {
          Alert.alert('Erreur', e?.message ?? 'Impossible de créer la session de récupération.');
        }
      }
    };
    Linking.getInitialURL().then(handleUrl);
    const sub = Linking.addEventListener('url', e => handleUrl(e.url));
    return () => sub.remove();
  }, []);

  // --- session au boot + écoute ---
  useEffect(() => {
    (async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) setUser({ email: session.user.email ?? '' });
      } finally {
        setBootLoading(false);
      }
    })();
    const { data: sub } = supabase.auth.onAuthStateChange((_e, session) => {
      setUser(session?.user ? { email: session.user.email ?? '' } : null);
    });
    return () => sub?.subscription?.unsubscribe();
  }, []);

  if (showReset) return <ResetPasswordScreen onDone={() => setShowReset(false)} />;

  if (bootLoading) {
    return (
      <ThemedView style={styles.center}>
        <ActivityIndicator />
        <ThemedText style={{ marginTop: 8 }}>Initialisation…</ThemedText>
      </ThemedView>
    );
  }

  const handleLogin = async () => {
    const e = email.trim();
    const p = password.trim();
    if (!e || !p) return Alert.alert('Erreur', 'Email et mot de passe requis');
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email: e, password: p });
    setLoading(false);
    if (error) Alert.alert('Erreur', error.message);
  };

  const handleForgot = async () => {
    const e = email.trim();
    if (!e) return Alert.alert('Erreur', 'Entre ton email d’abord 🙂');
    const redirectTo = makeRedirectTo();
    const { error } = await supabase.auth.resetPasswordForEmail(e, { redirectTo });
    if (error) Alert.alert('Erreur', error.message);
    else Alert.alert('Email envoyé', 'Ouvre le lien depuis Mail (iPhone).');
  };

  const handleLogout = async () => { await supabase.auth.signOut(); };

  // === ÉCRAN LOGIN ===
  if (!user) {
    return (
      <ThemedView style={styles.container}>
        <ThemedText style={[styles.title, { color: colors.text }]}>Connexion</ThemedText>
        <TextInput
          style={[styles.input, { borderColor: colors.border, color: colors.text }]}
          placeholder="Email"
          placeholderTextColor={colors.muted}
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
          autoCorrect={false}
        />
        <TextInput
          style={[styles.input, { borderColor: colors.border, color: colors.text }]}
          placeholder="Mot de passe"
          placeholderTextColor={colors.muted}
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          autoCapitalize="none"
          autoCorrect={false}
        />
        {loading ? <ActivityIndicator/> : <Button title="Se connecter" onPress={handleLogin} />}
        <View style={{ height: 8 }} />
        <Button title="Mot de passe oublié ?" onPress={handleForgot} />
      </ThemedView>
    );
  }

  // === ÉCRAN UTILISATEUR CONNECTÉ ===
  return (
    <ThemedView style={styles.container}>
      <ThemedText style={[styles.title, { color: colors.text }]}>Bienvenue {user.email}</ThemedText>
      <View style={{ height: 8 }} />

      <Button title="Mon profil" onPress={() => setShowProfile(true)} />
      <View style={{ height: 8 }} />

      <Button
        title={showCreatePlayer ? 'Fermer la création / gestion joueurs' : 'Créer / gérer mes joueurs'}
        onPress={() => setShowCreatePlayer(v => !v)}
      />
      {showCreatePlayer && (
        <View style={[styles.card, { borderColor: colors.border, backgroundColor: colors.card }]}>
          <CreateAndManagePlayers onDone={() => setShowCreatePlayer(false)} />
        </View>
      )}

      <View style={{ height: 8 }} />
      <Button title="Données & Confidentialité" onPress={() => setShowPrivacy(true)} />
      <View style={{ height: 8 }} />
      <Button title="Se déconnecter" onPress={handleLogout} />

      <Modal visible={showPrivacy} animationType="slide" presentationStyle="pageSheet">
        <ThemedView style={{ flex: 1 }}>
          <PrivacyScreen />
          <View style={{ padding: 16 }}>
            <Button title="Fermer" onPress={() => setShowPrivacy(false)} />
          </View>
        </ThemedView>
      </Modal>

      <ConsentBanner />
      <ProfileModal visible={showProfile} onClose={() => setShowProfile(false)} />
    </ThemedView>
  );
}

/** Créer + lister + renommer + supprimer mes joueurs (par org) */
function CreateAndManagePlayers({ onDone }: { onDone: () => void }) {
  const { colors } = useTheme();

  const [name, setName] = useState('');
  const [orgs, setOrgs] = useState<Array<{ id: string; name: string }>>([]);
  const [selectedOrgId, setSelectedOrgId] = useState<string>('');

  const [myPlayers, setMyPlayers] = useState<Array<{ id: string; name: string }>>([]);
  const [editing, setEditing] = useState<Record<string, string>>({});
  const [loadingOrgs, setLoadingOrgs] = useState(true);
  const [loadingPlayers, setLoadingPlayers] = useState(false);
  const [saving, setSaving] = useState(false);

  // Orgs (via memberships)
  useEffect(() => {
    (async () => {
      try {
        setLoadingOrgs(true);
        const { data: { user} } = await supabase.auth.getUser();
        if (!user) throw new Error('Non connecté');

        const { data, error } = await supabase
          .from('memberships')
          .select('orgs:org_id(id,name)')
          .eq('user_id', user.id);

        if (error) throw error;

        const flat = (data ?? []).map((r: any) => r.orgs).filter(Boolean) as Array<{ id: string; name: string }>;
        setOrgs(flat);
        if (flat.length === 1) setSelectedOrgId(flat[0].id);
      } catch (e: any) {
        Alert.alert('Erreur', e?.message ?? 'Chargement organisations impossible.');
      } finally {
        setLoadingOrgs(false);
      }
    })();
  }, []);

  // Players de l’org sélectionnée (owner = moi)
  const fetchPlayers = async (orgId: string) => {
    if (!orgId) { setMyPlayers([]); return; }
    try {
      setLoadingPlayers(true);
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Non connecté');

      const { data, error } = await supabase
        .from('players')
        .select('id,name')
        .eq('org_id', orgId)
        .eq('owner_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setMyPlayers(data ?? []);
      setEditing({});
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? 'Impossible de charger tes joueurs.');
    } finally {
      setLoadingPlayers(false);
    }
  };

  useEffect(() => { fetchPlayers(selectedOrgId); }, [selectedOrgId]);

  // Créer
  const createPlayer = async () => {
    if (!name.trim()) return Alert.alert('Erreur', 'Nom requis.');
    if (!selectedOrgId) return Alert.alert('Erreur', 'Choisis une organisation.');
    setSaving(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Non connecté');

      const { error } = await supabase
        .from('players')
        .insert({ name: name.trim(), org_id: selectedOrgId, owner_id: user.id });

      if (error) throw error;
      setName('');
      await fetchPlayers(selectedOrgId);
      Alert.alert('OK', 'Joueur créé.');
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? 'Création impossible.');
    } finally {
      setSaving(false);
    }
  };

  // Renommer
  const renamePlayer = async (id: string) => {
    const newName = (editing[id] ?? '').trim();
    if (!newName) return Alert.alert('Erreur', 'Nom requis.');
    try {
      const { error } = await supabase.from('players').update({ name: newName }).eq('id', id);
      if (error) throw error;
      await fetchPlayers(selectedOrgId);
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? 'Impossible de renommer.');
    }
  };

  // Supprimer
  const deletePlayer = async (id: string) => {
    try {
      const { error } = await supabase.from('players').delete().eq('id', id);
      if (error) throw error;
      await fetchPlayers(selectedOrgId);
    } catch (e: any) {
      Alert.alert('Erreur', e?.message ?? 'Suppression impossible.');
    }
  };

  return (
    <View>
      <ThemedText style={{ fontWeight: '700', marginBottom: 8 }}>Créer / gérer mes joueurs</ThemedText>

      {loadingOrgs ? (
        <ThemedText>Chargement des organisations…</ThemedText>
      ) : orgs.length === 0 ? (
        <ThemedText style={{ marginBottom: 12 }}>
          Aucune organisation trouvée. Demande à un admin de t’ajouter (memberships).
        </ThemedText>
      ) : (
        <View style={{ marginBottom: 12 }}>
          <ThemedText style={{ marginBottom: 6 }}>Choisis ton organisation :</ThemedText>
          {orgs.map(o => (
            <View key={o.id} style={{ marginBottom: 6 }}>
              <Pressable
                onPress={() => setSelectedOrgId(o.id)}
                style={({ pressed }) => [
                  {
                    padding: 10,
                    borderRadius: 8,
                    borderWidth: 1,
                    borderColor: selectedOrgId === o.id ? colors.primary : colors.border,
                    backgroundColor: pressed ? colors.card : 'transparent',
                  },
                ]}
              >
                <ThemedText>
                  {selectedOrgId === o.id ? '✅ ' : ''}{o.name || o.id}
                </ThemedText>
              </Pressable>
            </View>
          ))}
        </View>
      )}

      {/* Création */}
      <TextInput
        style={[styles.input, { borderColor: colors.border, color: colors.text }]}
        placeholder="Nom du joueur"
        placeholderTextColor={colors.muted}
        value={name}
        onChangeText={setName}
      />
      <Button title={saving ? '...' : 'Créer'} onPress={createPlayer} disabled={saving || !selectedOrgId} />

      {/* Liste + rename + delete */}
      <View style={{ marginTop: 16 }}>
        <ThemedText style={{ fontWeight: '600', marginBottom: 8 }}>Mes joueurs</ThemedText>
        {loadingPlayers ? (
          <ThemedText>Chargement…</ThemedText>
        ) : myPlayers.length === 0 ? (
          <ThemedText>Aucun joueur pour cette organisation.</ThemedText>
        ) : (
          myPlayers.map(p => (
            <View
              key={p.id}
              style={{
                borderWidth: 1,
                borderColor: colors.border,
                borderRadius: 8,
                padding: 8,
                marginBottom: 8,
                backgroundColor: colors.card,
              }}
            >
              <ThemedText style={{ marginBottom: 6 }}>Nom actuel : {p.name}</ThemedText>
              <TextInput
                style={[styles.input, { borderColor: colors.border, color: colors.text }]}
                placeholder="Nouveau nom"
                placeholderTextColor={colors.muted}
                value={editing[p.id] ?? ''}
                onChangeText={(t) => setEditing(prev => ({ ...prev, [p.id]: t }))}
              />
              <View style={{ flexDirection: 'row', gap: 8 }}>
                <View style={{ flex: 1 }}>
                  <Button title="Renommer" onPress={() => renamePlayer(p.id)} />
                </View>
                <View style={{ width: 8 }} />
                <View style={{ flex: 1 }}>
                  <Button color="#B00020" title="Supprimer" onPress={() => deletePlayer(p.id)} />
                </View>
              </View>
            </View>
          ))
        )}
      </View>

      <View style={{ height: 8 }} />
      <Button title="Fermer" onPress={onDone} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', padding: 20 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 18, fontWeight: '600', marginBottom: 12, textAlign: 'center' },
  input: { borderWidth: 1, padding: 10, borderRadius: 6, marginBottom: 12 },
  card: { marginTop: 12, padding: 12, borderWidth: 1, borderRadius: 8 },
});