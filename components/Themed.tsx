// components/Themed.tsx
import React from 'react';
import { View, Text, ViewProps, TextProps } from 'react-native';
import { useTheme } from '../src/theme';

export function ThemedView({ style, ...rest }: ViewProps) {
  const { colors } = useTheme();
  return <View style={[{ backgroundColor: colors.background }, style]} {...rest} />;
}

export function ThemedText({ style, ...rest }: TextProps) {
  const { colors } = useTheme();
  return <Text style={[{ color: colors.text }, style]} {...rest} />;
}