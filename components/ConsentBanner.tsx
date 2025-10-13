// components/ConsentBanner.tsx
import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Linking } from 'react-native';
import { recordConsent } from '../lib/privacy';

export default function ConsentBanner() {
  const [hidden, setHidden] = useState(false);

  const accept = async () => {
    try {
      await recordConsent(['essential_cookies', 'analytics'], '1.0.0');
      setHidden(true);
    } catch (e: any) {
      console.warn('consent error', e?.message);
    }
  };

  const refuse = async () => {
    try {
      await recordConsent(['essential_cookies'], '1.0.0');
      setHidden(true);
    } catch (e: any) {
      console.warn('consent error', e?.message);
    }
  };

  if (hidden) return null;

  return (
    <View style={styles.banner}>
      <Text style={styles.text}>
        Nous utilisons des cookies essentiels et de mesure d’audience (anonymisés).
      </Text>
      <View style={styles.row}>
        <TouchableOpacity onPress={refuse} style={[styles.btn, styles.outline]}>
          <Text>Refuser</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={accept} style={[styles.btn, styles.filled]}>
          <Text style={{ color: '#fff' }}>Accepter</Text>
        </TouchableOpacity>
      </View>
      <Text style={styles.link} onPress={() => Linking.openURL('https://kura.example/policy')}>
        Paramétrer / En savoir plus
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: { position: 'absolute', bottom: 0, left: 0, right: 0, padding: 12, backgroundColor: '#F3F4F6', borderTopWidth: 1, borderColor: '#E5E7EB' },
  text: { fontSize: 14, marginBottom: 8 },
  row: { flexDirection: 'row', gap: 8 },
  btn: { paddingVertical: 10, paddingHorizontal: 16, borderRadius: 8, borderWidth: 1, borderColor: '#D1D5DB' },
  outline: { backgroundColor: '#fff' },
  filled: { backgroundColor: '#111827', borderColor: '#111827' },
  link: { marginTop: 6, color: '#2563EB' },
});
