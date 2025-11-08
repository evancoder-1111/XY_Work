package com.xy.portal.controller;

import com.xy.portal.common.Result;
import com.xy.portal.dto.PortalEntryDTO;
import com.xy.portal.service.AuthService;
import com.xy.portal.service.PortalEntryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/portal/entries")
@RequiredArgsConstructor
public class PortalEntryController {
  private final PortalEntryService portalEntryService;
  private final AuthService authService;

  @GetMapping
  public Result<List<PortalEntryDTO>> getEntries(
      @RequestParam(defaultValue = "ACTIVE") String status,
      @RequestParam(required = false) String category,
      @RequestParam(required = false) String keyword) {
    List<PortalEntryDTO> entries;
    if (category != null || keyword != null) {
      entries = portalEntryService.searchEntries(status, category, keyword);
    } else {
      entries = portalEntryService.getAllEntries(status);
    }
    return Result.success(entries);
  }

  @GetMapping("/{id}")
  public Result<PortalEntryDTO> getEntryById(@PathVariable Long id) {
    PortalEntryDTO entry = portalEntryService.getEntryById(id);
    return Result.success(entry);
  }

  @PostMapping
  public Result<PortalEntryDTO> createEntry(
      @Valid @RequestBody PortalEntryDTO dto,
      @RequestHeader(value = "Authorization", required = false) String authorization) {
    Long createdBy = null;
    if (authorization != null && authorization.startsWith("Bearer ")) {
      String token = authorization.replace("Bearer ", "");
      createdBy = authService.getUserInfoFromToken(token);
    }
    PortalEntryDTO created = portalEntryService.createEntry(dto, createdBy);
    return Result.success(created);
  }

  @PutMapping("/{id}")
  public Result<PortalEntryDTO> updateEntry(
      @PathVariable Long id,
      @Valid @RequestBody PortalEntryDTO dto) {
    PortalEntryDTO updated = portalEntryService.updateEntry(id, dto);
    return Result.success(updated);
  }

  @DeleteMapping("/{id}")
  public Result<Void> deleteEntry(@PathVariable Long id) {
    portalEntryService.deleteEntry(id);
    return Result.success(null);
  }

  @PutMapping("/sort")
  public Result<Void> updateSortOrder(@RequestBody List<Long> entryIds) {
    portalEntryService.updateSortOrder(entryIds);
    return Result.success(null);
  }
}
