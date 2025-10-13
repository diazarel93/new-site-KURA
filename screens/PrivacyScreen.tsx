// screens/PrivacyScreen.tsx
import React, { useState } from 'react';
import { View, Text, Button, Alert, StyleSheet, Linking, ActivityIndicator } from 'react-native';
import { requestExport, softDeleteAccount } from '../lib/privacy';

export default function PrivacyScreen() {
  const [loading, setLoading] = useState<'exp'|'del'|null>(null);

  const onExport = async () => {
    try {
      setLoading('exp');
      const url = await requestExport();
      setLoading(null);
      Alert.alert('Export prêt', 'Ouverture du lien sécurisé (24h).');
      Linking.openURL(url);
    } catch (e: any) {
      setLoading(null);
      Alert.alert('Erreur export', e?.message ?? 'Échec export');
    }
  };

  const onDelete = async () => {
    Alert.alert('Suppression du compte', 'Votre compte sera désactivé immédiatement et supprimé sous 30 jours. Confirmer ?', [
      { text: 'Annuler' },
      { text: 'Confirmer', style: 'destructive', onPress: async () => {
        try {
          setLoading('del');
          await softDeleteAccount();
          setLoading(null);
          Alert.alert('Demande prise en compte', 'Suppression planifiée sous 30 jours.');
        } catch (e: any) {
          setLoading(null);
          Alert.alert('Erreur suppression', e?.message ?? 'Échec suppression');
        }
      }}
    ]);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Données & Confidentialité</Text>

      <Button title="Télécharger mes données (JSON)" onPress={onExport} />
      <View style={{ height: 12 }} />
      <Button title="Demander la suppression du compte" color="#ef4444" onPress={onDelete} />

      {loading && (
        <View style={styles.overlay}>
          <ActivityIndicator />
          <Text style={{ marginTop: 8 }}>{loading === 'exp' ? 'Préparation export…' : 'Envoi de la demande…'}</Text>
        </View>
      )}

      <View style={{ height: 20 }} />
      <Text style={styles.note}>
        Délai de réponse maximal : 30 jours. Pour toute question : privacy@kura.xxx
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, paddingTop: 48, gap: 12 },
  title: { fontSize: 20, fontWeight: '700', marginBottom: 8 },
  overlay: { position: 'absolute', left: 0, right: 0, bottom: 0, top: 0, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(255,255,255,0.6)' },
  note: { color: '#6b7280' },
});
