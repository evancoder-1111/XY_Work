package com.xy.portal.service;

import com.xy.portal.dto.PortalEntryDTO;
import com.xy.portal.entity.PortalEntry;
import com.xy.portal.repository.PortalEntryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PortalEntryService {
    private final PortalEntryRepository portalEntryRepository;

    public List<PortalEntryDTO> getAllEntries(String status) {
        List<PortalEntry> entries = portalEntryRepository.findByStatusOrderBySortOrderAsc(status);
        return entries.stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<PortalEntryDTO> searchEntries(String status, String category, String keyword) {
        List<PortalEntry> entries = portalEntryRepository.searchEntries(status, category, keyword);
        return entries.stream().map(this::toDTO).collect(Collectors.toList());
    }

    public PortalEntryDTO getEntryById(Long id) {
        PortalEntry entry = portalEntryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("入口不存在"));
        return toDTO(entry);
    }

    @Transactional
    public PortalEntryDTO createEntry(PortalEntryDTO dto, Long createdBy) {
        PortalEntry entry = new PortalEntry();
        entry.setName(dto.getName());
        entry.setDescription(dto.getDescription());
        entry.setIcon(dto.getIcon());
        entry.setUrl(dto.getUrl());
        entry.setCategory(dto.getCategory());
        entry.setStatus(dto.getStatus() != null ? dto.getStatus() : "ACTIVE");
        entry.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);
        entry.setCreatedBy(createdBy);

        PortalEntry saved = portalEntryRepository.save(entry);
        return toDTO(saved);
    }

    @Transactional
    public PortalEntryDTO updateEntry(Long id, PortalEntryDTO dto) {
        PortalEntry entry = portalEntryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("入口不存在"));

        if (dto.getName() != null) entry.setName(dto.getName());
        if (dto.getDescription() != null) entry.setDescription(dto.getDescription());
        if (dto.getIcon() != null) entry.setIcon(dto.getIcon());
        if (dto.getUrl() != null) entry.setUrl(dto.getUrl());
        if (dto.getCategory() != null) entry.setCategory(dto.getCategory());
        if (dto.getStatus() != null) entry.setStatus(dto.getStatus());
        if (dto.getSortOrder() != null) entry.setSortOrder(dto.getSortOrder());

        PortalEntry saved = portalEntryRepository.save(entry);
        return toDTO(saved);
    }

    @Transactional
    public void deleteEntry(Long id) {
        if (!portalEntryRepository.existsById(id)) {
            throw new IllegalArgumentException("入口不存在");
        }
        portalEntryRepository.deleteById(id);
    }

    @Transactional
    public void updateSortOrder(List<Long> entryIds) {
        for (int i = 0; i < entryIds.size(); i++) {
            final int sortOrder = i + 1;
            final Long entryId = entryIds.get(i);
            PortalEntry entry = portalEntryRepository.findById(entryId)
                    .orElseThrow(() -> new IllegalArgumentException("入口不存在: " + entryId));
            entry.setSortOrder(sortOrder);
            portalEntryRepository.save(entry);
        }
    }

    private PortalEntryDTO toDTO(PortalEntry entry) {
        PortalEntryDTO dto = new PortalEntryDTO();
        dto.setId(entry.getId());
        dto.setName(entry.getName());
        dto.setDescription(entry.getDescription());
        dto.setIcon(entry.getIcon());
        dto.setUrl(entry.getUrl());
        dto.setCategory(entry.getCategory());
        dto.setStatus(entry.getStatus());
        dto.setSortOrder(entry.getSortOrder());
        return dto;
    }
}

