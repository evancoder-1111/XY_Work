package com.xy.portal.service;

import com.xy.portal.dto.DashboardStatsDTO;
import com.xy.portal.repository.PortalEntryRepository;
import com.xy.portal.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final PortalEntryRepository portalEntryRepository;
    private final UserRepository userRepository;

    public DashboardStatsDTO getDashboardStats() {
        Integer totalEntries = portalEntryRepository.findByStatusOrderBySortOrderAsc("ACTIVE").size();
        
        // 今日访问统计（基于当前时间，可以后续接入真实访问日志）
        // 暂时使用模拟数据，实际项目中应该从访问日志表统计
        Integer todayVisits = totalEntries > 0 ? (int)(Math.random() * 50 + 10) : 0;
        
        // 待办任务统计（暂时使用模拟数据，实际应该从任务系统聚合）
        Integer pendingTasks = (int)(Math.random() * 10 + 3);
        
        Integer activeUsers = (int) userRepository.count();

        List<DashboardStatsDTO.RecentActivityDTO> recentActivities = new ArrayList<>();
        recentActivities.add(new DashboardStatsDTO.RecentActivityDTO(
                "访问",
                "访问了 OA系统",
                LocalDateTime.now().minusHours(2).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
        ));
        recentActivities.add(new DashboardStatsDTO.RecentActivityDTO(
                "创建",
                "创建了新的门户入口",
                LocalDateTime.now().minusDays(1).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
        ));

        List<DashboardStatsDTO.TaskDTO> tasks = new ArrayList<>();
        tasks.add(new DashboardStatsDTO.TaskDTO(
                1L,
                "完成项目文档",
                "进行中",
                "高",
                LocalDateTime.now().plusDays(3).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
        ));

        return new DashboardStatsDTO(
                totalEntries,
                todayVisits,
                pendingTasks,
                activeUsers,
                recentActivities,
                tasks
        );
    }
}

