-- 星元空间统一数字门户初始数据脚本

USE `xy_portal`;

-- 插入测试用户
-- 密码均为：admin123（已使用 BCrypt 加密）
-- 生成方式：使用 BCryptPasswordEncoder.encode("admin123")
INSERT INTO `users` (`username`, `password`, `nickname`, `email`, `role`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwy8pQ5O', '管理员', 'admin@xy.com', 'ADMIN', 'ACTIVE'),
('user1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwy8pQ5O', '测试用户1', 'user1@xy.com', 'USER', 'ACTIVE')
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

-- 插入示例门户入口
INSERT INTO `portal_entries` (`name`, `description`, `icon`, `url`, `category`, `status`, `sort_order`, `created_by`) VALUES
('OA系统', '企业办公自动化系统', '📋', 'https://oa.example.com', '业务系统', 'ACTIVE', 1, 1),
('CRM系统', '客户关系管理系统', '👥', 'https://crm.example.com', '业务系统', 'ACTIVE', 2, 1),
('项目管理', '项目协作管理平台', '📊', 'https://project.example.com', '协作工具', 'ACTIVE', 3, 1),
('知识库', '企业知识管理平台', '📚', 'https://wiki.example.com', '协作工具', 'ACTIVE', 4, 1),
('财务系统', '企业财务管理系统', '💰', 'https://finance.example.com', '管理系统', 'ACTIVE', 5, 1),
('人事系统', '人力资源管理系统', '👔', 'https://hr.example.com', '管理系统', 'ACTIVE', 6, 1)
ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP;

