/**
 * BEGINNER GUIDE:
 * File: PasswordUtil.java
 * Role: Utility helpers: shared low-level helpers used by services/controllers.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.utils;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * xindongriji-backend password hashing utility (PBKDF2).
 */
public final class PasswordUtil {
  private static final String ALGO = "PBKDF2WithHmacSHA256";
  private static final int ITERATIONS = 65536;
  private static final int KEY_LENGTH = 256;
  private static final int SALT_LENGTH = 16;

  private PasswordUtil() {}

  public static String hash(String password) {
    byte[] salt = new byte[SALT_LENGTH];
    new SecureRandom().nextBytes(salt);
    byte[] hash = pbkdf2(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
    return ITERATIONS + ":" + base64(salt) + ":" + base64(hash);
  }

  public static boolean verify(String password, String stored) {
    String[] parts = stored.split(":");
    if (parts.length != 3) {
      return false;
    }
    int iterations = Integer.parseInt(parts[0]);
    byte[] salt = fromBase64(parts[1]);
    byte[] hash = fromBase64(parts[2]);
    byte[] test = pbkdf2(password.toCharArray(), salt, iterations, hash.length * 8);
    return slowEquals(hash, test);
  }

  private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
    try {
      PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
      SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGO);
      return skf.generateSecret(spec).getEncoded();
    } catch (NoSuchAlgorithmException | InvalidKeySpecException ex) {
      throw new IllegalStateException("password hash error", ex);
    }
  }

  private static boolean slowEquals(byte[] a, byte[] b) {
    int diff = a.length ^ b.length;
    for (int i = 0; i < a.length && i < b.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  private static String base64(byte[] data) {
    return Base64.getEncoder().encodeToString(data);
  }

  private static byte[] fromBase64(String data) {
    return Base64.getDecoder().decode(data);
  }
}
