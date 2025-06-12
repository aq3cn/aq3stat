-- aq3stat 网站统计系统数据库初始化脚本
-- 适用于MySQL 5.7+

-- 创建数据库
CREATE DATABASE IF NOT EXISTS aq3stat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE aq3stat;

-- 用户组表
CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL COMMENT '用户组名称',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否管理员',
  `site_admin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '网站管理权限',
  `user_admin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '用户管理权限',
  `run_time_stat` tinyint(1) NOT NULL DEFAULT '0' COMMENT '实时统计权限',
  `client_stat` tinyint(1) NOT NULL DEFAULT '0' COMMENT '客户端统计权限',
  `admin_website` tinyint(1) NOT NULL DEFAULT '0' COMMENT '管理所有网站',
  `hide_icon` tinyint(1) NOT NULL DEFAULT '0' COMMENT '隐藏统计图标',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户组表';

-- 用户表
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `email` varchar(100) NOT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `group_id` int(11) NOT NULL COMMENT '用户组ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  UNIQUE KEY `idx_email` (`email`),
  KEY `idx_group_id` (`group_id`),
  CONSTRAINT `fk_users_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 网站表
CREATE TABLE IF NOT EXISTS `websites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `name` varchar(100) NOT NULL COMMENT '网站名称',
  `url` varchar(255) NOT NULL COMMENT '网站地址',
  `description` varchar(255) DEFAULT NULL COMMENT '网站描述',
  `is_public` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否公开',
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始统计时间',
  `click_in_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后访问时间',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_websites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='网站表';

-- 统计数据表
CREATE TABLE IF NOT EXISTS `stats` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `website_id` int(11) NOT NULL COMMENT '网站ID',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
  `leave_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '离开时间',
  `ip` varchar(50) NOT NULL COMMENT '访问者IP',
  `count` int(11) NOT NULL DEFAULT '1' COMMENT '访问次数',
  `referer` varchar(255) DEFAULT NULL COMMENT '来源URL',
  `base_referer` varchar(255) DEFAULT NULL COMMENT '来源域名',
  `search_engine` varchar(50) DEFAULT NULL COMMENT '搜索引擎',
  `keyword` varchar(255) DEFAULT NULL COMMENT '搜索关键词',
  `location` varchar(255) DEFAULT NULL COMMENT '访问页面URL',
  `screen_color` int(11) DEFAULT NULL COMMENT '屏幕颜色深度',
  `screen_size` varchar(20) DEFAULT NULL COMMENT '屏幕分辨率',
  `browser` varchar(50) DEFAULT NULL COMMENT '浏览器类型',
  `os` varchar(50) DEFAULT NULL COMMENT '操作系统',
  `os_lang` varchar(20) DEFAULT NULL COMMENT '操作系统语言',
  `has_alexa_bar` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有Alexa工具栏',
  `address` varchar(255) DEFAULT NULL COMMENT '地址信息',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `isp` varchar(50) DEFAULT NULL COMMENT 'ISP',
  `re_visit_times` int(11) NOT NULL DEFAULT '1' COMMENT '重访次数',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_website_id` (`website_id`),
  KEY `idx_time` (`time`),
  KEY `idx_ip` (`ip`),
  CONSTRAINT `fk_stats_website` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='统计数据表';

-- IP地址库表
CREATE TABLE IF NOT EXISTS `ip_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_ip` bigint(20) unsigned NOT NULL COMMENT '起始IP',
  `end_ip` bigint(20) unsigned NOT NULL COMMENT '结束IP',
  `address1` varchar(255) DEFAULT NULL COMMENT '地址信息1（省市）',
  `address2` varchar(255) DEFAULT NULL COMMENT '地址信息2（ISP）',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_start_ip` (`start_ip`),
  KEY `idx_end_ip` (`end_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='IP地址库表';

-- 邮件表
CREATE TABLE IF NOT EXISTS `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL COMMENT '发送者ID',
  `receivers` text COMMENT '接收者列表',
  `mail_subject` varchar(255) NOT NULL COMMENT '邮件主题',
  `mail_body` text NOT NULL COMMENT '邮件内容',
  `mail_type` varchar(10) NOT NULL DEFAULT 'TEXT' COMMENT '邮件类型（TEXT/HTML）',
  `sent_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_emails_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邮件表';

-- 邮件配置表
CREATE TABLE IF NOT EXISTS `email_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL COMMENT '类型（REGISTER/RESET_PASSWORD）',
  `is_enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用',
  `mail_subject` varchar(255) NOT NULL COMMENT '邮件主题',
  `mail_body` text NOT NULL COMMENT '邮件内容',
  `mail_type` varchar(10) NOT NULL DEFAULT 'TEXT' COMMENT '邮件类型（TEXT/HTML）',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邮件配置表';

-- 搜索引擎表
CREATE TABLE IF NOT EXISTS `search_engines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '搜索引擎名称',
  `domains` varchar(255) NOT NULL COMMENT '域名列表（逗号分隔）',
  `query_params` varchar(100) NOT NULL COMMENT '查询参数名（逗号分隔）',
  `display_order` int(11) NOT NULL DEFAULT '0' COMMENT '显示顺序',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='搜索引擎表';

-- 插入默认用户组数据
INSERT INTO `groups` (`title`, `is_admin`, `site_admin`, `user_admin`, `run_time_stat`, `client_stat`, `admin_website`, `hide_icon`)
VALUES
('Administrator', 1, 1, 1, 1, 1, 1, 0),
('Regular User', 0, 1, 0, 1, 1, 0, 0),
('Premium User', 0, 1, 0, 1, 1, 0, 1);

-- 插入默认管理员用户（密码：admin123）
INSERT INTO `users` (`username`, `password`, `email`, `group_id`)
VALUES
('admin', '$2a$10$NfFIzP4XJ1bK7fZPQxML1.JZty5QN.oc.1SOFxHZQVkK1K1RvP5TS', 'admin@aq3stat.com', 1);

-- 插入默认搜索引擎数据
INSERT INTO `search_engines` (`name`, `domains`, `query_params`, `display_order`)
VALUES
('Baidu', 'baidu.com', 'wd,word', 1),
('Google', 'google.cn,google.com', 'q', 2),
('Yahoo', 'yahoo.com', 'p', 3),
('Bing', 'bing.com', 'q', 4),
('Sogou', 'sogou.com', 'query', 5);

-- 插入默认邮件配置
INSERT INTO `email_configs` (`type`, `is_enabled`, `mail_subject`, `mail_body`, `mail_type`)
VALUES
('REGISTER', 1, 'Welcome to aq3stat - Registration Confirmation', 'Dear {{username}},\n\nThank you for registering with aq3stat. Your account has been created successfully.\n\nUsername: {{username}}\n\nPlease visit our website to start tracking your websites.\n\nBest regards,\nThe aq3stat Team', 'TEXT'),
('RESET_PASSWORD', 1, 'aq3stat - Password Reset', 'Dear {{username}},\n\nYou have requested to reset your password. Please use the following link to reset your password:\n\n{{reset_link}}\n\nIf you did not request this, please ignore this email.\n\nBest regards,\nThe aq3stat Team', 'TEXT');

-- 创建统计数据汇总视图
CREATE OR REPLACE VIEW `stat_summary` AS
SELECT
    w.id AS website_id,
    w.name AS website_name,
    w.user_id,
    u.username,
    COUNT(DISTINCT s.ip) AS total_ip,
    SUM(s.count) AS total_pv,
    COUNT(DISTINCT CASE WHEN DATE(s.time) = CURDATE() THEN s.ip END) AS today_ip,
    SUM(CASE WHEN DATE(s.time) = CURDATE() THEN s.count ELSE 0 END) AS today_pv,
    COUNT(DISTINCT CASE WHEN DATE(s.time) = DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN s.ip END) AS yesterday_ip,
    SUM(CASE WHEN DATE(s.time) = DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN s.count ELSE 0 END) AS yesterday_pv,
    w.start_time,
    DATEDIFF(CURDATE(), DATE(w.start_time)) + 1 AS days_running
FROM
    websites w
    LEFT JOIN stats s ON w.id = s.website_id
    LEFT JOIN users u ON w.user_id = u.id
WHERE
    w.deleted_at IS NULL
    AND (s.deleted_at IS NULL OR s.deleted_at IS NULL)
GROUP BY
    w.id, w.name, w.user_id, u.username, w.start_time;
