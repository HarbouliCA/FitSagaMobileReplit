import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { Text, TextInput, Button, ActivityIndicator } from 'react-native-paper';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';

import { RootState } from '../../redux/store';
import { AuthStackParamList } from '../../navigation/AuthNavigator';
import { loginUser, clearError } from '../../redux/features/authSlice';
import { theme, typography, spacing } from '../../theme';

type LoginScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList, 'Login'>;

const LoginScreen: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  
  const dispatch = useDispatch();
  const navigation = useNavigation<LoginScreenNavigationProp>();
  const { loading, error } = useSelector((state: RootState) => state.auth);

  const handleLogin = () => {
    if (email.trim() === '' || password === '') {
      // Handle empty fields validation
      return;
    }
    
    dispatch(clearError());
    dispatch(loginUser({ email, password }));
  };

  const goToRegister = () => {
    navigation.navigate('Register');
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.logoContainer}>
          <View style={styles.logoBox}>
            <MaterialCommunityIcons name="dumbbell" size={40} color="#FFFFFF" />
          </View>
          <Text style={styles.title}>FitSAGA</Text>
          <Text style={styles.subtitle}>Gym Management App</Text>
        </View>

        <View style={styles.formContainer}>
          <Text style={styles.formTitle}>Sign In</Text>
          
          {error && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          )}
          
          <TextInput
            label="Email"
            value={email}
            onChangeText={setEmail}
            mode="outlined"
            autoCapitalize="none"
            keyboardType="email-address"
            style={styles.input}
            outlineColor={theme.colors.primary}
          />
          
          <TextInput
            label="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry={!passwordVisible}
            mode="outlined"
            style={styles.input}
            outlineColor={theme.colors.primary}
            right={
              <TextInput.Icon 
                icon={passwordVisible ? "eye-off" : "eye"}
                onPress={() => setPasswordVisible(!passwordVisible)}
              />
            }
          />
          
          <Button
            mode="contained"
            onPress={handleLogin}
            style={styles.button}
            loading={loading}
            disabled={loading}
          >
            {loading ? 'Signing In...' : 'Sign In'}
          </Button>
          
          <View style={styles.registerContainer}>
            <Text style={styles.registerText}>Don't have an account?</Text>
            <TouchableOpacity onPress={goToRegister}>
              <Text style={styles.registerLink}>Sign Up</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  scrollContent: {
    flexGrow: 1,
    paddingVertical: spacing.xl,
    paddingHorizontal: spacing.m,
  },
  logoContainer: {
    alignItems: 'center',
    marginTop: spacing.xl,
    marginBottom: spacing.xl,
  },
  logoBox: {
    width: 80,
    height: 80,
    backgroundColor: theme.colors.primary,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.m,
  },
  title: {
    ...typography.h1,
    color: theme.colors.primary,
    marginTop: spacing.s,
  },
  subtitle: {
    ...typography.body2,
    color: theme.colors.placeholder,
    marginTop: spacing.xs,
  },
  formContainer: {
    paddingHorizontal: spacing.m,
  },
  formTitle: {
    ...typography.h2,
    marginBottom: spacing.l,
    textAlign: 'center',
  },
  input: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  button: {
    marginTop: spacing.m,
    paddingVertical: spacing.xs,
    backgroundColor: theme.colors.primary,
  },
  errorContainer: {
    backgroundColor: '#FFEBEE',
    padding: spacing.m,
    borderRadius: 4,
    marginBottom: spacing.m,
  },
  errorText: {
    color: theme.colors.error,
    textAlign: 'center',
  },
  registerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: spacing.l,
  },
  registerText: {
    ...typography.body2,
  },
  registerLink: {
    ...typography.body2,
    color: theme.colors.primary,
    marginLeft: spacing.xs,
    fontWeight: 'bold',
  },
});

export default LoginScreen;