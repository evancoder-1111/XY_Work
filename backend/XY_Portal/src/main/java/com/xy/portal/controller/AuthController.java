package com.xy.portal.controller;

import com.xy.portal.common.Result;
import com.xy.portal.dto.LoginRequest;
import com.xy.portal.dto.LoginResponse;
import com.xy.portal.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
  private final AuthService authService;

  @PostMapping("/sso/login")
  public Result<LoginResponse> ssoLogin(@Valid @RequestBody LoginRequest request) {
    LoginResponse response = authService.ssoLogin(request);
    return Result.success(response);
  }

  @GetMapping("/user/info")
  public Result<LoginResponse.UserInfo> getUserInfo(
      @RequestHeader(value = "Authorization", required = false) String authorization) {
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      throw new IllegalArgumentException("未授权访问");
    }
    String token = authorization.replace("Bearer ", "");
    Long userId = authService.getUserInfoFromToken(token);
    LoginResponse.UserInfo userInfo = authService.getUserInfo(userId);
    return Result.success(userInfo);
  }

  @PostMapping("/logout")
  public Result<Void> logout() {
    return Result.success(null);
  }
}
