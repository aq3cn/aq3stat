-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: aq3stat
-- ------------------------------------------------------
-- Server version	8.0.16

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `email_configs`
--

DROP TABLE IF EXISTS `email_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_configs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) DEFAULT '1',
  `mail_subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mail_body` text COLLATE utf8mb4_unicode_ci,
  `mail_type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_email_configs_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_configs`
--

LOCK TABLES `email_configs` WRITE;
/*!40000 ALTER TABLE `email_configs` DISABLE KEYS */;
INSERT INTO `email_configs` VALUES (1,'REGISTER',1,'Welcome to aq3stat - Registration Confirmation','Dear {{username}},\n\nThank you for registering with aq3stat. Your account has been created successfully.\n\nUsername: {{username}}\n\nPlease visit our website to start tracking your websites.\n\nBest regards,\nThe aq3stat Team','TEXT','2025-05-28 14:18:46.043','2025-05-28 14:18:46.043',NULL),(2,'RESET_PASSWORD',1,'aq3stat - Password Reset','Dear {{username}},\n\nYou have requested to reset your password. Please use the following link to reset your password:\n\n{{reset_link}}\n\nIf you did not request this, please ignore this email.\n\nBest regards,\nThe aq3stat Team','TEXT','2025-05-28 14:18:46.045','2025-05-28 14:18:46.045',NULL);
/*!40000 ALTER TABLE `email_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emails` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `receivers` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mail_subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mail_body` text COLLATE utf8mb4_unicode_ci,
  `mail_type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_time` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_emails_deleted_at` (`deleted_at`),
  KEY `fk_emails_user` (`user_id`),
  CONSTRAINT `fk_emails_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emails`
--

LOCK TABLES `emails` WRITE;
/*!40000 ALTER TABLE `emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  `site_admin` tinyint(1) DEFAULT '0',
  `user_admin` tinyint(1) DEFAULT '0',
  `run_time_stat` tinyint(1) DEFAULT '0',
  `client_stat` tinyint(1) DEFAULT '0',
  `admin_website` tinyint(1) DEFAULT '0',
  `hide_icon` tinyint(1) DEFAULT '0',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_groups_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
INSERT INTO `groups` VALUES (1,'Administrator',1,1,1,1,1,1,0,'2025-05-28 14:18:45.938','2025-05-28 14:18:45.938',NULL),(2,'Regular User',0,1,0,1,1,0,0,'2025-05-28 14:18:45.941','2025-05-28 14:18:45.941',NULL),(3,'Premium User',0,1,0,1,1,0,1,'2025-05-28 14:18:45.943','2025-05-28 14:18:45.943',NULL);
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_data`
--

DROP TABLE IF EXISTS `ip_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ip_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `start_ip` bigint(20) unsigned NOT NULL,
  `end_ip` bigint(20) unsigned NOT NULL,
  `address1` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ip_data_start_ip` (`start_ip`),
  KEY `idx_ip_data_end_ip` (`end_ip`),
  KEY `idx_ip_data_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_data`
--

LOCK TABLES `ip_data` WRITE;
/*!40000 ALTER TABLE `ip_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_engines`
--

DROP TABLE IF EXISTS `search_engines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_engines` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `domains` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `query_params` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_order` bigint(20) DEFAULT '0',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_search_engines_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_engines`
--

LOCK TABLES `search_engines` WRITE;
/*!40000 ALTER TABLE `search_engines` DISABLE KEYS */;
INSERT INTO `search_engines` VALUES (1,'Baidu','baidu.com','wd,word',1,'2025-05-28 14:18:46.030','2025-05-28 14:18:46.030',NULL),(2,'Google','google.cn,google.com','q',2,'2025-05-28 14:18:46.033','2025-05-28 14:18:46.033',NULL),(3,'Yahoo','yahoo.com','p',3,'2025-05-28 14:18:46.036','2025-05-28 14:18:46.036',NULL),(4,'Bing','bing.com','q',4,'2025-05-28 14:18:46.038','2025-05-28 14:18:46.038',NULL),(5,'Sogou','sogou.com','query',5,'2025-05-28 14:18:46.040','2025-05-28 14:18:46.040',NULL);
/*!40000 ALTER TABLE `search_engines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stats` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `website_id` bigint(20) NOT NULL,
  `time` datetime(3) DEFAULT NULL,
  `leave_time` datetime(3) DEFAULT NULL,
  `ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `count` bigint(20) DEFAULT '1',
  `referer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `base_referer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `search_engine` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `keyword` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screen_color` bigint(20) DEFAULT NULL,
  `screen_size` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os_lang` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `has_alexa_bar` tinyint(1) DEFAULT '0',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `province` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isp` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `re_visit_times` bigint(20) DEFAULT '1',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_stats_time` (`time`),
  KEY `idx_stats_ip` (`ip`),
  KEY `idx_stats_deleted_at` (`deleted_at`),
  KEY `idx_stats_website_id` (`website_id`),
  CONSTRAINT `fk_stats_website` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stats`
--

LOCK TABLES `stats` WRITE;
/*!40000 ALTER TABLE `stats` DISABLE KEYS */;
INSERT INTO `stats` VALUES (1,6,'2025-05-28 17:05:11.474','2025-05-28 17:10:52.865','172.20.0.1',3,'https://example.com','https://example.com','','','https://test.com/page1',24,'1920X1080','Other','Other','zh-cn',0,'','','',1,'2025-05-28 17:05:11.480','2025-05-28 17:10:52.866',NULL),(2,7,'2025-05-28 17:18:11.538','2025-05-28 19:26:42.771','172.20.0.1',25,'','','','','http://localhost/a.html',24,'2136X1190','Chrome','Linux','other',0,'','','',1,'2025-05-28 17:18:11.540','2025-05-28 19:26:42.773',NULL),(3,6,'2025-05-27 10:00:00.000','2025-05-27 10:05:00.000','192.168.1.100',5,'https://google.com',NULL,NULL,NULL,'https://test5.com/page1',24,'1920x1080','Chrome 120','Windows 10','zh-CN',0,NULL,NULL,NULL,1,NULL,NULL,NULL),(4,6,'2025-05-27 11:00:00.000','2025-05-27 11:03:00.000','192.168.1.101',3,'https://baidu.com',NULL,NULL,NULL,'https://test5.com/page2',24,'1440x900','Firefox 119','macOS','zh-CN',0,NULL,NULL,NULL,1,NULL,NULL,NULL),(5,7,'2025-05-26 14:00:00.000','2025-05-26 14:02:00.000','192.168.1.102',2,'',NULL,NULL,NULL,'https://sdfsdfsd.com/home',24,'375x667','Safari 17','iOS','zh-CN',0,NULL,NULL,NULL,1,NULL,NULL,NULL),(6,7,'2025-05-25 16:00:00.000','2025-05-25 16:01:00.000','192.168.1.103',1,'https://google.com',NULL,NULL,NULL,'https://sdfsdfsd.com/about',24,'360x640','Chrome 120','Android','zh-CN',0,NULL,NULL,NULL,1,NULL,NULL,NULL),(7,8,'2025-05-24 09:00:00.000','2025-05-24 09:10:00.000','192.168.1.104',10,'https://bing.com',NULL,NULL,NULL,'https://example1.com/index',24,'1920x1080','Edge 119','Windows 11','en-US',0,NULL,NULL,NULL,1,NULL,NULL,NULL),(8,7,'2025-05-29 10:18:25.050','2025-05-29 10:18:27.241','172.20.0.1',3,'','','','','http://127.0.0.1/a.html',24,'2560X1352','Chrome','Linux','other',0,'','','',2,'2025-05-29 10:18:25.054','2025-05-29 10:18:27.242',NULL);
/*!40000 ALTER TABLE `stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `group_id` int(11) NOT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'admin','$2a$10$isuTzh1s0T8VxejAOG0KF.pRuBAr.CsAb37kj8eb9dvpsFATQafku','admin_final@aq3stat.com','13900139000','Final Address',1,'2025-05-28 10:52:07.000','2025-05-28 19:05:33.532',NULL),(3,'testuser1','$2a$10$UslWsic0vxjjAfJqfUDvbOlIf4je4vWW6pB5J1Rx0ZznH9zoweL0C','test1_updated@example.com','','',2,'2025-05-28 09:51:09.000','2025-05-28 18:07:09.867',NULL),(4,'testuser2','$2a$10$hgBqHAdpPOiQMIj2O2XTxeR0ZyRre2c5hTYB15n.a6Uvct355UHXC','test2@example.com','','',2,'2025-05-28 09:51:09.000','2025-05-28 18:48:44.137',NULL),(5,'testuser3','$2a$10$MUA894QJOtE.hV0rHhQQEu1J67dBS0d9nMSRllkycpF5P7SwCIFR6','test3@example.com','','',3,'2025-05-28 09:51:09.000','2025-05-28 18:48:50.524',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `websites`
--

DROP TABLE IF EXISTS `websites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `websites` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT '0',
  `start_time` datetime(3) DEFAULT NULL,
  `click_in_time` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_websites_deleted_at` (`deleted_at`),
  KEY `fk_websites_user` (`user_id`),
  CONSTRAINT `fk_websites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `websites`
--

LOCK TABLES `websites` WRITE;
/*!40000 ALTER TABLE `websites` DISABLE KEYS */;
INSERT INTO `websites` VALUES (6,2,'测试网站5','https://test5.com','测试网站5',1,'2025-05-28 16:43:54.511','2025-05-29 16:16:34.274','2025-05-28 16:43:54.511','2025-05-29 16:16:34.274',NULL),(7,2,'ddd','https://sdfsdfsd.com','dfsdfsdfdf',0,'2025-05-28 16:45:33.877','2025-05-29 15:17:41.999','2025-05-28 16:45:33.877','2025-05-29 15:17:41.999',NULL),(8,3,'ccc','https://example1.com','ccc1',1,'2025-05-28 09:51:20.000','2025-05-29 14:05:24.427','2025-05-28 09:51:20.000','2025-05-29 14:05:24.427',NULL),(9,4,'bbb','https://example2.com','bbb1',1,'2025-05-28 09:51:20.000',NULL,'2025-05-28 09:51:20.000','2025-05-28 09:51:20.000',NULL),(10,5,'aaa','https://private.com','aaa1',0,'2025-05-28 09:51:20.000',NULL,'2025-05-28 09:51:20.000','2025-05-28 09:51:20.000',NULL);
/*!40000 ALTER TABLE `websites` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-29 16:20:10
