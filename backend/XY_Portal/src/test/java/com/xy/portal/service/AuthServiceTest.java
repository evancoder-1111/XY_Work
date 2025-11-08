package com.xy.portal.service;

import com.xy.portal.dto.LoginRequest;
import com.xy.portal.dto.LoginResponse;
import com.xy.portal.entity.User;
import com.xy.portal.repository.UserRepository;
import com.xy.portal.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

  @Mock
  private UserRepository userRepository;

  @Mock
  private JwtUtil jwtUtil;

  @Mock
  private PasswordEncoder passwordEncoder;

  @InjectMocks
  private AuthService authService;

  private User testUser;

  @BeforeEach
  void setUp() {
    testUser = new User();
    testUser.setId(1L);
    testUser.setUsername("admin");
    testUser.setPassword("$2a$10$encoded");
    testUser.setEmail("admin@xy.com");
    testUser.setNickname("管理员");
    testUser.setRole("ADMIN");
    testUser.setStatus("ACTIVE");
  }

  @Test
  void testSSOLogin_Success() {
    LoginRequest request = new LoginRequest();
    request.setUsername("admin");
    request.setPassword("admin123");

    when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));
    when(passwordEncoder.matches("admin123", testUser.getPassword())).thenReturn(true);
    when(jwtUtil.generateToken(1L, "admin")).thenReturn("test-token");

    LoginResponse response = authService.ssoLogin(request);

    assertNotNull(response);
    assertEquals("test-token", response.getToken());
    assertNotNull(response.getUser());
    assertEquals("admin", response.getUser().getUsername());
  }

  @Test
  void testSSOLogin_UserNotFound() {
    LoginRequest request = new LoginRequest();
    request.setUsername("notfound");
    request.setPassword("password");

    when(userRepository.findByUsername("notfound")).thenReturn(Optional.empty());

    assertThrows(IllegalArgumentException.class, () -> {
      authService.ssoLogin(request);
    });
  }

  @Test
  void testSSOLogin_WrongPassword() {
    LoginRequest request = new LoginRequest();
    request.setUsername("admin");
    request.setPassword("wrongpassword");

    when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));
    when(passwordEncoder.matches("wrongpassword", testUser.getPassword())).thenReturn(false);

    assertThrows(IllegalArgumentException.class, () -> {
      authService.ssoLogin(request);
    });
  }
}
