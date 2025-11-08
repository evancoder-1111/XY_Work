package com.xy.portal.service;

import com.xy.portal.dto.LoginRequest;
import com.xy.portal.dto.LoginResponse;
import com.xy.portal.entity.User;
import com.xy.portal.repository.UserRepository;
import com.xy.portal.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {
  private final UserRepository userRepository;
  private final JwtUtil jwtUtil;
  private final PasswordEncoder passwordEncoder;

  public LoginResponse ssoLogin(LoginRequest request) {
    Optional<User> userOpt = userRepository.findByUsername(request.getUsername());

    if (userOpt.isEmpty()) {
      throw new IllegalArgumentException("用户名或密码错误");
    }

    User user = userOpt.get();

    if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
      throw new IllegalArgumentException("用户名或密码错误");
    }

    if (!"ACTIVE".equals(user.getStatus())) {
      throw new IllegalArgumentException("用户已被禁用");
    }

    String token = jwtUtil.generateToken(user.getId(), user.getUsername());

    LoginResponse.UserInfo userInfo = new LoginResponse.UserInfo(
        user.getId(),
        user.getUsername(),
        user.getEmail(),
        user.getNickname(),
        user.getAvatar(),
        user.getRole());

    return new LoginResponse(token, userInfo);
  }

  public LoginResponse.UserInfo getUserInfo(Long userId) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

    return new LoginResponse.UserInfo(
        user.getId(),
        user.getUsername(),
        user.getEmail(),
        user.getNickname(),
        user.getAvatar(),
        user.getRole());
  }

  public Long getUserInfoFromToken(String token) {
    return jwtUtil.getUserIdFromToken(token);
  }
}
