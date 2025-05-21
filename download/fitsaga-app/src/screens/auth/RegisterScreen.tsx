import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { Text, TextInput, Button, Snackbar } from 'react-native-paper';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';

import { RootState } from '../../redux/store';
import { AuthStackParamList } from '../../navigation/AuthNavigator';
import { registerUser, clearError } from '../../redux/features/authSlice';
import { theme, typography, spacing } from '../../theme';

type RegisterScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList, 'Register'>;

const RegisterScreen: React.FC = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);
  
  const dispatch = useDispatch();
  const navigation = useNavigation<RegisterScreenNavigationProp>();
  const { loading, error } = useSelector((state: RootState) => state.auth);

  const validateForm = (): boolean => {
    if (name.trim() === '') {
      setValidationError('Please enter your name');
      return false;
    }
    
    if (email.trim() === '') {
      setValidationError('Please enter your email');
      return false;
    }
    
    if (!/\S+@\S+\.\S+/.test(email)) {
      setValidationError('Please enter a valid email address');
      return false;
    }
    
    if (password === '') {
      setValidationError('Please enter a password');
      return false;
    }
    
    if (password.length < 6) {
      setValidationError('Password must be at least 6 characters');
      return false;
    }
    
    if (password !== confirmPassword) {
      setValidationError('Passwords do not match');
      return false;
    }
    
    return true;
  };

  const handleRegister = () => {
    setValidationError(null);
    
    if (!validateForm()) {
      return;
    }
    
    dispatch(clearError());
    dispatch(registerUser({ 
      email, 
      password, 
      name,
      role: 'client' // Default role for new registrations
    }));
  };

  const goToLogin = () => {
    navigation.navigate('Login');
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
          <Text style={styles.formTitle}>Create Account</Text>
          
          {(error || validationError) && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>{error || validationError}</Text>
            </View>
          )}
          
          <TextInput
            label="Full Name"
            value={name}
            onChangeText={setName}
            mode="outlined"
            style={styles.input}
            outlineColor={theme.colors.primary}
          />
          
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
          
          <TextInput
            label="Confirm Password"
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            secureTextEntry={!passwordVisible}
            mode="outlined"
            style={styles.input}
            outlineColor={theme.colors.primary}
          />
          
          <Button
            mode="contained"
            onPress={handleRegister}
            style={styles.button}
            loading={loading}
            disabled={loading}
          >
            {loading ? 'Creating Account...' : 'Sign Up'}
          </Button>
          
          <View style={styles.loginContainer}>
            <Text style={styles.loginText}>Already have an account?</Text>
            <TouchableOpacity onPress={goToLogin}>
              <Text style={styles.loginLink}>Sign In</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>

      <Snackbar
        visible={!!validationError}
        onDismiss={() => setValidationError(null)}
        duration={3000}
      >
        {validationError}
      </Snackbar>
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
    marginTop: spacing.m,
    marginBottom: spacing.m,
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
  loginContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: spacing.l,
  },
  loginText: {
    ...typography.body2,
  },
  loginLink: {
    ...typography.body2,
    color: theme.colors.primary,
    marginLeft: spacing.xs,
    fontWeight: 'bold',
  },
});

export default RegisterScreen;