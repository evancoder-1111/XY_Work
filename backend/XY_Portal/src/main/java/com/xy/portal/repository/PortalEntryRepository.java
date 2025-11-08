package com.xy.portal.repository;

import com.xy.portal.entity.PortalEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PortalEntryRepository extends JpaRepository<PortalEntry, Long> {
    List<PortalEntry> findByStatusOrderBySortOrderAsc(String status);
    
    @Query("SELECT e FROM PortalEntry e WHERE e.status = :status AND " +
           "(:category IS NULL OR e.category = :category) AND " +
           "(:keyword IS NULL OR e.name LIKE %:keyword% OR e.description LIKE %:keyword%) " +
           "ORDER BY e.sortOrder ASC")
    List<PortalEntry> searchEntries(@Param("status") String status,
                                    @Param("category") String category,
                                    @Param("keyword") String keyword);
}

