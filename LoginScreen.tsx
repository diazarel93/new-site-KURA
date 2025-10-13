import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet, Alert } from 'react-native';
import { supabase } from '../lib/supabaseClient'; // adapte le chemin si besoin

export default function LoginScreen() {
  const [email, setEmail] = useState('');

  async function signInWithEmail() {
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        // ⚠️ Mets l’URL Expo affichée dans ton terminal (celle du QR code)
        emailRedirectTo: 'exp://192.168.1.135:8081',
      },
    });

    if (error) {
      Alert.alert('Erreur', error.message);
    } else {
      Alert.alert('Vérifie ton mail', 'Un lien magique t’a été envoyé 📩');
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Connexion</Text>
      <TextInput
        style={styles.input}
        placeholder="Ton email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />
      <Button title="Se connecter" onPress={signInWithEmail} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    padding: 10,
    marginBottom: 15,
    borderRadius: 5,
  },
});