package com.xy.portal.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
  private Integer totalEntries;
  private Integer todayVisits;
  private Integer pendingTasks;
  private Integer activeUsers;
  private List<RecentActivityDTO> recentActivities;
  private List<TaskDTO> tasks;

  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RecentActivityDTO {
    private String type;
    private String description;
    private String time;
  }

  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class TaskDTO {
    private Long id;
    private String title;
    private String status;
    private String priority;
    private String dueDate;
  }
}
