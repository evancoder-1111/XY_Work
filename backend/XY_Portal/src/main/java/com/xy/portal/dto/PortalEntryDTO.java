package com.xy.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PortalEntryDTO {
    private Long id;

    @NotBlank(message = "系统名称不能为空")
    private String name;

    private String description;

    private String icon;

    @NotBlank(message = "访问地址不能为空")
    private String url;

    private String category;

    private String status;

    private Integer sortOrder;
}

