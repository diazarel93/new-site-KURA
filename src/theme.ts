// src/theme.ts
import { useColorScheme } from 'react-native';

export function useTheme() {
  const scheme = useColorScheme();
  const isDark = scheme === 'dark';
  return {
    isDark,
    colors: {
      background: isDark ? '#000000' : '#FFFFFF',
      text:       isDark ? '#FFFFFF' : '#000000',
      primary:    '#007AFF',
      border:     isDark ? '#333333' : '#CCCCCC',
      card:       isDark ? '#111111' : '#F8F8F8',
      danger:     '#B00020',
      muted:      isDark ? '#AAAAAA' : '#666666',
    },
  };
}