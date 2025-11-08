package com.xy.portal.service;

import com.xy.portal.dto.PortalEntryDTO;
import com.xy.portal.entity.PortalEntry;
import com.xy.portal.repository.PortalEntryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PortalEntryServiceTest {

    @Mock
    private PortalEntryRepository portalEntryRepository;

    @InjectMocks
    private PortalEntryService portalEntryService;

    private PortalEntry testEntry;

    @BeforeEach
    void setUp() {
        testEntry = new PortalEntry();
        testEntry.setId(1L);
        testEntry.setName("OA系统");
        testEntry.setDescription("企业办公自动化系统");
        testEntry.setUrl("https://oa.example.com");
        testEntry.setStatus("ACTIVE");
    }

    @Test
    void testGetAllEntries() {
        when(portalEntryRepository.findByStatusOrderBySortOrderAsc("ACTIVE"))
                .thenReturn(Arrays.asList(testEntry));

        List<PortalEntryDTO> result = portalEntryService.getAllEntries("ACTIVE");

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("OA系统", result.get(0).getName());
    }

    @Test
    void testCreateEntry() {
        PortalEntryDTO dto = new PortalEntryDTO();
        dto.setName("新系统");
        dto.setUrl("https://new.example.com");
        dto.setStatus("ACTIVE");

        PortalEntry savedEntry = new PortalEntry();
        savedEntry.setId(2L);
        savedEntry.setName("新系统");
        savedEntry.setUrl("https://new.example.com");
        savedEntry.setStatus("ACTIVE");

        when(portalEntryRepository.save(any(PortalEntry.class))).thenReturn(savedEntry);

        PortalEntryDTO result = portalEntryService.createEntry(dto, 1L);

        assertNotNull(result);
        assertEquals("新系统", result.getName());
        verify(portalEntryRepository, times(1)).save(any(PortalEntry.class));
    }

    @Test
    void testUpdateEntry() {
        PortalEntryDTO dto = new PortalEntryDTO();
        dto.setName("更新后的系统");

        when(portalEntryRepository.findById(1L)).thenReturn(Optional.of(testEntry));
        when(portalEntryRepository.save(any(PortalEntry.class))).thenReturn(testEntry);

        PortalEntryDTO result = portalEntryService.updateEntry(1L, dto);

        assertNotNull(result);
        assertEquals("更新后的系统", result.getName());
    }

    @Test
    void testDeleteEntry() {
        when(portalEntryRepository.existsById(1L)).thenReturn(true);
        doNothing().when(portalEntryRepository).deleteById(1L);

        portalEntryService.deleteEntry(1L);

        verify(portalEntryRepository, times(1)).deleteById(1L);
    }

    @Test
    void testDeleteEntry_NotFound() {
        when(portalEntryRepository.existsById(999L)).thenReturn(false);

        assertThrows(IllegalArgumentException.class, () -> {
            portalEntryService.deleteEntry(999L);
        });
    }
}

