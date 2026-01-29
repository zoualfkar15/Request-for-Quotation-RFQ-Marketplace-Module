-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Generation Time: Jan 29, 2026 at 03:51 PM
-- Server version: 8.0.44
-- PHP Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `yii2basic`
--

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_general_ci NOT NULL,
  `slug` varchar(140) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`id`, `name`, `slug`, `created_at`, `updated_at`) VALUES
(1, 'General Supplies', 'general-supplies', 1769553051, 1769553051),
(2, 'Construction', 'construction', 1769553051, 1769553051),
(3, 'IT & Electronics', 'it-electronics', 1769553051, 1769553051);

-- --------------------------------------------------------

--
-- Table structure for table `category_subscription`
--

CREATE TABLE `category_subscription` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category_subscription`
--

INSERT INTO `category_subscription` (`id`, `user_id`, `category_id`, `created_at`) VALUES
(45, 5, 1, 1769623622),
(48, 3, 1, 1769692502),
(50, 5, 3, 1769697101),
(51, 5, 2, 1769697130),
(52, 3, 3, 1769698097),
(53, 3, 2, 1769698098),
(54, 6, 2, 1769699564),
(55, 6, 1, 1769699565),
(56, 6, 3, 1769699565),
(61, 8, 1, 1769699920),
(62, 8, 3, 1769699926),
(63, 7, 2, 1769700013),
(64, 7, 1, 1769700014),
(65, 12, 2, 1769701477),
(66, 12, 1, 1769701480),
(67, 12, 3, 1769701481),
(68, 11, 2, 1769701573),
(69, 11, 1, 1769701574),
(70, 11, 3, 1769701574);

-- --------------------------------------------------------

--
-- Table structure for table `migration`
--

CREATE TABLE `migration` (
  `version` varchar(180) COLLATE utf8mb4_general_ci NOT NULL,
  `apply_time` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migration`
--

INSERT INTO `migration` (`version`, `apply_time`) VALUES
('m000000_000000_base', 1769455912),
('m260126_000001_create_user_table', 1769455920),
('m260126_000002_create_category_table', 1769455920),
('m260126_000003_create_category_subscription_table', 1769455920),
('m260126_000004_create_rfq_request_table', 1769455920),
('m260126_000005_create_rfq_quotation_table', 1769455920),
('m260126_000006_create_notification_table', 1769455920),
('m260126_000007_create_offer_table', 1769455920),
('m260126_000008_create_refresh_token_table', 1769455921),
('m260126_000009_add_email_verified_to_user', 1769463759),
('m260126_000010_create_otp_table', 1769463759),
('m260126_000011_seed_default_categories', 1769553051),
('m260128_000012_add_phone_to_user', 1769617417),
('m260128_000015_change_rfq_quotation_status_to_string', 1769618049),
('m260128_000016_change_rfq_request_status_to_string', 1769619480),
('m260128_000017_change_offer_status_to_string', 1769619480);

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `id` int UNSIGNED NOT NULL,
  `recipient_user_id` int UNSIGNED NOT NULL,
  `type` varchar(60) COLLATE utf8mb4_general_ci NOT NULL,
  `payload_json` text COLLATE utf8mb4_general_ci NOT NULL,
  `is_read` tinyint NOT NULL DEFAULT '0',
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`id`, `recipient_user_id`, `type`, `payload_json`, `is_read`, `created_at`) VALUES
(1, 3, 'offer_created', '{\"offer_id\":1,\"category_id\":1,\"company_id\":5}', 1, 1769554324),
(2, 3, 'quotation_created', '{\"request_id\":1,\"quotation_id\":1,\"company_id\":5}', 1, 1769554389),
(3, 3, 'quotation_created', '{\"request_id\":3,\"quotation_id\":2,\"company_id\":5}', 1, 1769554403),
(4, 3, 'quotation_created', '{\"request_id\":5,\"quotation_id\":3,\"company_id\":5}', 0, 1769617092),
(5, 3, 'offer_created', '{\"offer_id\":2,\"category_id\":1,\"company_id\":5}', 0, 1769620973),
(6, 3, 'quotation_created', '{\"request_id\":4,\"quotation_id\":5,\"company_id\":5}', 0, 1769621117),
(7, 3, 'offer_created', '{\"offer_id\":3,\"category_id\":1,\"company_id\":5}', 0, 1769623254),
(8, 3, 'quotation_created', '{\"request_id\":2,\"quotation_id\":6,\"company_id\":5}', 0, 1769623305),
(9, 3, 'quotation_created', '{\"request_id\":7,\"quotation_id\":7,\"company_id\":5}', 0, 1769623851),
(10, 3, 'quotation_created', '{\"request_id\":6,\"quotation_id\":8,\"company_id\":5}', 0, 1769623858),
(11, 3, 'offer_created', '{\"offer_id\":4,\"category_id\":1,\"company_id\":5}', 0, 1769624061),
(12, 3, 'offer_created', '{\"offer_id\":5,\"category_id\":1,\"company_id\":5}', 0, 1769624914),
(13, 3, 'offer_created', '{\"offer_id\":8,\"category_id\":2,\"company_id\":5}', 0, 1769638569),
(14, 3, 'offer_created', '{\"offer_id\":9,\"category_id\":2,\"company_id\":5}', 0, 1769638599),
(15, 3, 'offer_created', '{\"offer_id\":10,\"category_id\":2,\"company_id\":5}', 0, 1769690065),
(16, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690783),
(17, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690783),
(18, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690783),
(19, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690783),
(20, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690783),
(21, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690801),
(22, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690801),
(23, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690801),
(24, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690801),
(25, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769690801),
(26, 1, 'test_broadcast', '{\"title\":\"Dev Broadcast\",\"message\":\"Hello from backend\"}', 0, 1769690956),
(27, 2, 'test_broadcast', '{\"title\":\"Dev Broadcast\",\"message\":\"Hello from backend\"}', 0, 1769690956),
(28, 3, 'test_broadcast', '{\"title\":\"Dev Broadcast\",\"message\":\"Hello from backend\"}', 0, 1769690956),
(29, 4, 'test_broadcast', '{\"title\":\"Dev Broadcast\",\"message\":\"Hello from backend\"}', 0, 1769690956),
(30, 5, 'test_broadcast', '{\"title\":\"Dev Broadcast\",\"message\":\"Hello from backend\"}', 0, 1769690956),
(31, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691051),
(32, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691051),
(33, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691051),
(34, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691051),
(35, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691051),
(36, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691075),
(37, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691075),
(38, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691075),
(39, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691075),
(40, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691075),
(41, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691085),
(42, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691085),
(43, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691085),
(44, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691085),
(45, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691085),
(46, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691093),
(47, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691093),
(48, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691093),
(49, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691093),
(50, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691093),
(51, 3, 'offer_created', '{\"offer_id\":11,\"category_id\":2,\"company_id\":5}', 0, 1769691125),
(52, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Should appear\"}', 0, 1769691256),
(53, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Should appear\"}', 0, 1769691256),
(54, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Should appear\"}', 0, 1769691256),
(55, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Should appear\"}', 0, 1769691256),
(56, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Should appear\"}', 0, 1769691256),
(57, 3, 'offer_created', '{\"offer_id\":12,\"category_id\":2,\"company_id\":5}', 0, 1769691295),
(58, 3, 'offer_created', '{\"offer_id\":13,\"category_id\":3,\"company_id\":5}', 0, 1769691320),
(59, 3, 'offer_created', '{\"offer_id\":14,\"category_id\":3,\"company_id\":5}', 0, 1769691344),
(60, 3, 'offer_created', '{\"offer_id\":15,\"category_id\":2,\"company_id\":5}', 0, 1769691353),
(61, 3, 'offer_created', '{\"offer_id\":16,\"category_id\":2,\"company_id\":5}', 0, 1769691392),
(62, 3, 'offer_created', '{\"offer_id\":17,\"category_id\":3,\"company_id\":5}', 0, 1769691421),
(63, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691437),
(64, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691437),
(65, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691437),
(66, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691437),
(67, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691437),
(68, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691443),
(69, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691443),
(70, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691443),
(71, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691443),
(72, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691443),
(73, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691457),
(74, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691457),
(75, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691457),
(76, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691457),
(77, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691457),
(78, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691464),
(79, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691464),
(80, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691464),
(81, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691464),
(82, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691464),
(83, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691473),
(84, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691473),
(85, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691473),
(86, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691473),
(87, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691473),
(88, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691479),
(89, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691479),
(90, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691479),
(91, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691479),
(92, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691479),
(93, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691561),
(94, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691561),
(95, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691561),
(96, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691561),
(97, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769691561),
(98, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692052),
(99, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692052),
(100, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692052),
(101, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692052),
(102, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692052),
(103, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692059),
(104, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692059),
(105, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692059),
(106, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692059),
(107, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692059),
(108, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692063),
(109, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692063),
(110, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692063),
(111, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692063),
(112, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692063),
(113, 1, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692070),
(114, 2, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692070),
(115, 3, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692070),
(116, 4, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692070),
(117, 5, 'test_broadcast', '{\"title\":\"Test\",\"message\":\"Hello\",\"foo\":\"bar\"}', 0, 1769692070),
(118, 3, 'offer_created', '{\"offer_id\":18,\"category_id\":1,\"company_id\":5}', 0, 1769692086),
(119, 3, 'offer_created', '{\"offer_id\":19,\"category_id\":1,\"company_id\":5}', 0, 1769692091),
(120, 3, 'offer_created', '{\"offer_id\":20,\"category_id\":1,\"company_id\":5}', 0, 1769692094),
(121, 3, 'offer_created', '{\"offer_id\":21,\"category_id\":1,\"company_id\":5}', 0, 1769692105),
(122, 3, 'offer_created', '{\"offer_id\":22,\"category_id\":2,\"company_id\":5}', 0, 1769692453),
(123, 3, 'offer_created', '{\"offer_id\":23,\"category_id\":1,\"company_id\":5}', 0, 1769692466),
(124, 3, 'offer_created', '{\"offer_id\":27,\"category_id\":2,\"company_id\":5}', 0, 1769692528),
(125, 3, 'offer_created', '{\"offer_id\":30,\"category_id\":2,\"company_id\":5}', 0, 1769698111),
(126, 3, 'offer_created', '{\"offer_id\":31,\"category_id\":2,\"company_id\":7}', 0, 1769699558),
(127, 3, 'offer_created', '{\"offer_id\":32,\"category_id\":2,\"company_id\":7}', 0, 1769699741),
(128, 6, 'offer_created', '{\"offer_id\":32,\"category_id\":2,\"company_id\":7}', 0, 1769699741),
(129, 6, 'quotation_created', '{\"request_id\":14,\"quotation_id\":9,\"company_id\":7}', 0, 1769699790),
(130, 3, 'offer_created', '{\"offer_id\":33,\"category_id\":2,\"company_id\":7}', 0, 1769699898),
(131, 6, 'offer_created', '{\"offer_id\":33,\"category_id\":2,\"company_id\":7}', 0, 1769699898),
(132, 3, 'quotation_created', '{\"request_id\":13,\"quotation_id\":10,\"company_id\":7}', 0, 1769700309),
(133, 3, 'quotation_created', '{\"request_id\":12,\"quotation_id\":11,\"company_id\":7}', 0, 1769700320),
(134, 11, 'quotation_created', '{\"request_id\":16,\"quotation_id\":12,\"company_id\":12}', 1, 1769701512),
(135, 3, 'offer_created', '{\"offer_id\":34,\"category_id\":2,\"company_id\":12}', 0, 1769701567),
(136, 6, 'offer_created', '{\"offer_id\":34,\"category_id\":2,\"company_id\":12}', 0, 1769701567),
(137, 3, 'offer_created', '{\"offer_id\":35,\"category_id\":2,\"company_id\":12}', 0, 1769701589),
(138, 6, 'offer_created', '{\"offer_id\":35,\"category_id\":2,\"company_id\":12}', 0, 1769701589),
(139, 11, 'offer_created', '{\"offer_id\":35,\"category_id\":2,\"company_id\":12}', 1, 1769701589);

-- --------------------------------------------------------

--
-- Table structure for table `offer`
--

CREATE TABLE `offer` (
  `id` int UNSIGNED NOT NULL,
  `company_id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `title` varchar(190) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci NOT NULL,
  `unit` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `min_quantity` decimal(12,3) DEFAULT NULL,
  `price_per_unit` decimal(12,2) NOT NULL,
  `delivery_city` varchar(120) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `available_from` datetime DEFAULT NULL,
  `available_until` datetime DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'active',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `offer`
--

INSERT INTO `offer` (`id`, `company_id`, `category_id`, `title`, `description`, `unit`, `min_quantity`, `price_per_unit`, `delivery_city`, `available_from`, `available_until`, `status`, `created_at`, `updated_at`) VALUES
(1, 5, 1, 'adsafds', '23324324', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769554324, 1769554324),
(2, 5, 1, 'kljlkjjl', 'lkjklj', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769620973, 1769620973),
(3, 5, 1, 'dgf', 'asfdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769623254, 1769623254),
(4, 5, 1, 'sdfds', 'asdsdfd', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769624061, 1769624061),
(5, 5, 1, '3453433', 'erterter', 'piece', NULL, 100.00, NULL, NULL, NULL, 'inactive', 1769624914, 1769624927),
(6, 5, 2, 'adas', 'sadasdassad', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769638455, 1769638455),
(7, 5, 2, 'adas', 'sadasdassad', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769638459, 1769638459),
(8, 5, 2, 'adas', 'sadasdassad', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769638569, 1769638569),
(9, 5, 2, 'asdads', 'asasasds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769638599, 1769638599),
(10, 5, 2, '234234', 'dsaf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769690065, 1769690065),
(11, 5, 2, 'sdfdadf', 'dsfsf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691125, 1769691125),
(12, 5, 2, 'asdasd', 'asdsad', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691295, 1769691295),
(13, 5, 3, 'asdasd', 'asdsad', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691320, 1769691320),
(14, 5, 3, 'swerw', 'wrew', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691344, 1769691344),
(15, 5, 2, 'vvv', 'sdf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691353, 1769691353),
(16, 5, 2, 'cccc', 'asdsada', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691392, 1769691392),
(17, 5, 3, 'sad', 'asasa', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769691421, 1769691421),
(18, 5, 1, 'aaaaa', 'sdsfdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692086, 1769692086),
(19, 5, 1, 'aaaaa', 'sdsfdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692091, 1769692091),
(20, 5, 1, 'aaaaa', 'sdsfdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692094, 1769692094),
(21, 5, 1, 'aaaaa', 'sdsfdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692105, 1769692105),
(22, 5, 2, 'vvvvv', 'sfsddf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692453, 1769692453),
(23, 5, 1, 'sdfsd', 'sdfdsf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692466, 1769692466),
(24, 5, 2, 'sdfd', 'sfsdf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692484, 1769692484),
(25, 5, 2, 'sfsdf', 'sdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692500, 1769692500),
(26, 5, 2, 'sdfsdfsd', 'sfdsfsf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692516, 1769692516),
(27, 5, 2, '2342243', '2343232', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692528, 1769692528),
(28, 5, 2, 'kkkkkeee', 'sdffdsf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769692544, 1769692544),
(29, 5, 2, 'last offer', 'aasdfdsf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769698091, 1769698091),
(30, 5, 2, 'asdfs', 'sfdsdf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769698111, 1769698111),
(31, 7, 2, 'nnn', 'aaasdfasd', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769699558, 1769699558),
(32, 7, 2, 'mmmmsdf', 'sfdd', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769699741, 1769699741),
(33, 7, 2, 'kkkk', 'sfsfsd', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769699898, 1769699898),
(34, 12, 2, 'bbbb', 'sdfsddf', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769701567, 1769701567),
(35, 12, 2, 'last new offer', 'asdfds', 'piece', NULL, 100.00, NULL, NULL, NULL, 'active', 1769701589, 1769701589);

-- --------------------------------------------------------

--
-- Table structure for table `otp`
--

CREATE TABLE `otp` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `email` varchar(190) COLLATE utf8mb4_general_ci NOT NULL,
  `purpose` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `code_hash` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `expires_at` int NOT NULL,
  `last_sent_at` int NOT NULL,
  `used_at` int DEFAULT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `otp`
--

INSERT INTO `otp` (`id`, `user_id`, `email`, `purpose`, `code_hash`, `expires_at`, `last_sent_at`, `used_at`, `created_at`) VALUES
(1, 3, 'user2@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769465309, 1769464709, 1769464710, 1769464709),
(2, 2, 'user@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769465687, 1769465087, 1769465105, 1769465087),
(3, 3, 'user2@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769465973, 1769465373, NULL, 1769465373),
(4, 3, 'user2@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769466049, 1769465449, 1769465453, 1769465449),
(5, 3, 'user2@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769466125, 1769465525, 1769465529, 1769465525),
(6, 4, 'test@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769466157, 1769465557, 1769465560, 1769465557),
(7, 5, 'company@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769466204, 1769465604, 1769465606, 1769465604),
(8, 6, 'user_test@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769700052, 1769699452, 1769699455, 1769699452),
(9, 7, 'company_test@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769700137, 1769699537, 1769699539, 1769699537),
(10, 8, 'aaa@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769700453, 1769699853, 1769699854, 1769699853),
(11, 9, 'aaa2@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769701454, 1769700854, 1769700858, 1769700854),
(12, 10, 'test_uset@gmial.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769701849, 1769701249, 1769701251, 1769701249),
(13, 11, 'testuser.1@gmial.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769701947, 1769701347, 1769701356, 1769701347),
(14, 12, 'company.test@gmail.com', 'verify', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1769702003, 1769701403, 1769701405, 1769701403);

-- --------------------------------------------------------

--
-- Table structure for table `refresh_token`
--

CREATE TABLE `refresh_token` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `expires_at` int NOT NULL,
  `revoked_at` int DEFAULT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `refresh_token`
--

INSERT INTO `refresh_token` (`id`, `user_id`, `token_hash`, `expires_at`, `revoked_at`, `created_at`) VALUES
(1, 1, '74fd3cc06403fdf67ac11a2a0519dae29ab6de4de0d45dd75c7a985ce090d73a', 1772053872, 1769461885, 1769461872),
(2, 2, '9635a1134a073b0293a30d7f28e7b194ad75b79d9be09c1eb429d0b1b8ce15a8', 1772053966, 1769461971, 1769461966),
(3, 3, '8b8f78183a2f777a29505db63c6884b066bd3601ba97c1a697dcac22c865ab30', 1772054120, NULL, 1769462120),
(4, 3, '1ca25819b1af549e0055d9e778ed9599a8edc61ca795f4beaf548b9deb57016f', 1772054164, NULL, 1769462164),
(5, 3, '747400c67983693c6508df38fd616ee6d33301428dc5d148c4722309371c3d27', 1772054182, 1769462218, 1769462182),
(6, 3, 'fc74105bde485e5fe8445b1602759d1f840c54a520b22f688ba345b992129914', 1772054243, 1769463366, 1769462243),
(7, 2, 'ec0c6571e183e3d2f59afde048e7722b3ccb386cc126e0b82f2b1b3b08275ef8', 1772054543, NULL, 1769462543),
(8, 3, '92d4eb200b678c1ce819a8049d890adc0bca15c011c12e4e10fe617c051e8943', 1772056941, 1769464946, 1769464941),
(9, 2, '4a7fa7aeb7f35f17db04b11beb0d1854f6922908424df3917b71009c2155f978', 1772057105, 1769465111, 1769465105),
(10, 3, '05f59822383ce542ed8d8406e0df2b75313537282565a8987b05c44587a636ff', 1772057453, 1769465487, 1769465453),
(11, 3, '083677f136a4968479e7c054bf7d36fedd644b43b10a7d078feca07b7c526396', 1772057529, 1769465532, 1769465529),
(12, 4, 'd1230a71105d9d909bacf1496ff4f03b32918eb59ee8df9a62b8b27d27a1c88a', 1772057557, NULL, 1769465557),
(13, 4, 'c16074b7a6c14c5e03eaf034973a64070f3bf9a9a511e9c3792eeda412724076', 1772057560, 1769465566, 1769465560),
(14, 5, '5b462b200951b8ac4a3c13d22d26b192fedc51e7b6e8f561fd85f4b2ab75b390', 1772057604, NULL, 1769465604),
(15, 5, 'dcce3e09b3b37fea35ec3fadbc5d498316f73ed5eef96642d99bdfd288d1f297', 1772057606, NULL, 1769465606),
(16, 3, '5d2522e8c5b9931b5c9d8f976b38f96856e7db10afd73df6442cf6524ffae67b', 1772144828, 1769554284, 1769552828),
(17, 5, 'cddd6514d8461387bd28ffddd94145a5f68320b0bab4155e863b46b3948e5e15', 1772146298, 1769554414, 1769554298),
(18, 2, '43d21bae4dab8ce6cfa62e6175091ca6ebba54ecb10c7c82680f3af9e73c3022', 1772146430, 1769554436, 1769554430),
(19, 3, '3cb23e19fdb47c3a1480157b2d2e6b9b17f00d1d305197c50988dcaf73b8ff01', 1772146452, 1769606766, 1769554452),
(20, 3, 'e1e162b4eb5d502e2bf9f2c980ecf597f40cddca45250f60aec890baf695df6d', 1772198829, 1769609857, 1769606829),
(21, 3, '8a556cebd9b108b689d557ff29efb57390579802eb00de19c8a74b39d005efbb', 1772201889, 1769698124, 1769609889),
(22, 5, '48c26a447bf4b7384e126dc256ba1f4eb19df9d561b256b3d580398ea41790c1', 1772209066, 1769698129, 1769617066),
(23, 6, '6053ad5cd6143c8010ee6ee4f9914d7891a036f110555afcca30b54177c1f348', 1772291452, NULL, 1769699452),
(24, 6, '24d5afba74ebeceffef128e80e4b978d2a57edbc0a44acbee8be2a430ef5bda5', 1772291455, 1769699839, 1769699455),
(25, 7, '2cbbfbbca65d781f1501d34d30c6ee4c319bee9fd8cfd8d8771cc04aa1315417', 1772291537, NULL, 1769699537),
(26, 7, 'ab6e5a8cc74cb2a37f58d7a0d949911cead94038248f9019018c710d8d50dffb', 1772291539, 1769700870, 1769699539),
(27, 8, '3badeb6b9791fc105e7289a941462ee951e132ed652a6ca4aa469461fc1c0c6b', 1772291853, NULL, 1769699853),
(28, 8, '115f4b63d35dd336eabd63aa7f15835c7b937a977f65f1ac168be71275e2a7af', 1772291854, 1769700751, 1769699854),
(29, 9, 'e5f2066823ff8699aec31f57a47ad0b065ab3b2a3dfd4f5ffe60622f61af4be7', 1772292854, NULL, 1769700854),
(30, 9, '4a21a2eb184b873de35dd66e69404209a519e7e918b7b87dcf2cb9678187ac82', 1772292858, 1769700879, 1769700858),
(31, 10, '9fdb5d41565df596a241436a668d74c7a6f45521c91a068f96d882985257b9f8', 1772293249, NULL, 1769701249),
(32, 10, '0f42a926ac7ea962141eb7deadde525d2d0ed5025a930932860a1705c576f048', 1772293251, 1769701277, 1769701251),
(33, 11, 'd41aa4a06a39efd7ffe2d6947511d88c67da638a57a7417282648c62156ef3a2', 1772293347, NULL, 1769701347),
(34, 11, '117355a3241bb352cc8fa2f16808f44fe26199aff144f763e2637bb939380f1e', 1772293356, NULL, 1769701356),
(35, 12, '9679121ee25aec19cf476452940b2006b716ef33ec1217450d88f39c1c5d6b7e', 1772293403, NULL, 1769701403),
(36, 12, '10d67fcee0f21190b98f40e95b0d9a001e9018275e3be73917a8fe3e3a5471fb', 1772293405, NULL, 1769701405);

-- --------------------------------------------------------

--
-- Table structure for table `rfq_quotation`
--

CREATE TABLE `rfq_quotation` (
  `id` int UNSIGNED NOT NULL,
  `request_id` int UNSIGNED NOT NULL,
  `company_id` int UNSIGNED NOT NULL,
  `price_per_unit` decimal(12,2) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `delivery_time_days` int UNSIGNED NOT NULL,
  `delivery_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `payment_terms` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `notes` text COLLATE utf8mb4_general_ci,
  `valid_until` datetime NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'created',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rfq_quotation`
--

INSERT INTO `rfq_quotation` (`id`, `request_id`, `company_id`, `price_per_unit`, `total_price`, `delivery_time_days`, `delivery_cost`, `payment_terms`, `notes`, `valid_until`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 12:00:00', 'created', 1769554389, 1769555211),
(2, 3, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 12:00:00', 'accepted', 1769554403, 1769619750),
(3, 5, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'accepted', 1769617092, 1769620923),
(5, 4, 5, 100.00, 100.00, 3, 0.00, 'Cash', 'mmmmmm', '2026-02-10 09:00:00', 'created', 1769621117, 1769621117),
(6, 2, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'created', 1769623305, 1769623305),
(7, 7, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'accepted', 1769623851, 1769627119),
(8, 6, 5, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'created', 1769623858, 1769623858),
(9, 14, 7, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'accepted', 1769699790, 1769699797),
(10, 13, 7, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'created', 1769700309, 1769700309),
(11, 12, 7, 100.00, 100.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'created', 1769700320, 1769700320),
(12, 16, 12, 100.00, 12.00, 3, 0.00, 'Cash', NULL, '2026-02-10 09:00:00', 'accepted', 1769701512, 1769701521);

-- --------------------------------------------------------

--
-- Table structure for table `rfq_request`
--

CREATE TABLE `rfq_request` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `title` varchar(190) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `unit` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `delivery_city` varchar(120) COLLATE utf8mb4_general_ci NOT NULL,
  `delivery_lat` decimal(10,7) DEFAULT NULL,
  `delivery_lng` decimal(10,7) DEFAULT NULL,
  `required_delivery_date` date NOT NULL,
  `budget_min` decimal(12,2) DEFAULT NULL,
  `budget_max` decimal(12,2) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'open',
  `awarded_quotation_id` int UNSIGNED DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rfq_request`
--

INSERT INTO `rfq_request` (`id`, `user_id`, `category_id`, `title`, `description`, `quantity`, `unit`, `delivery_city`, `delivery_lat`, `delivery_lng`, `required_delivery_date`, `budget_min`, `budget_max`, `expires_at`, `status`, `awarded_quotation_id`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '232342', '234234234234', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'open', NULL, 1769553099, 1769555211),
(2, 3, 1, '232342', '234234234234', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'open', NULL, 1769553363, 1769553384),
(3, 3, 1, '2342', 'asdfasdfs', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'awarded', 2, 1769553565, 1769619750),
(4, 3, 1, '33345345', 'asdsdsdada', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'open', NULL, 1769611421, 1769611421),
(5, 3, 1, 'mmmmm', 'nnnnn', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'awarded', 3, 1769612058, 1769620923),
(6, 3, 2, 'ssdsf', 'sdfsdsdfsd', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 12:00:00', 'open', NULL, 1769614316, 1769614316),
(7, 3, 2, 'sdfsdf', 'sdfsdf', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'awarded', 7, 1769623381, 1769627119),
(8, 3, 3, 'last', 'sdfsdfs', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769623488, 1769623488),
(9, 3, 2, 'asddas', 'asdasdas', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', 100.00, 1000.00, '2026-02-02 09:00:00', 'open', NULL, 1769691231, 1769691231),
(10, 3, 1, 'sdfsdsdf', 'asfdsfd', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769697114, 1769697114),
(11, 3, 2, 'sdf', 'sdfsfdfs', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769697128, 1769697128),
(12, 3, 1, 'new', 'aaaaa', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769697150, 1769697150),
(13, 3, 2, 'new', 'aaaaa', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769697158, 1769697158),
(14, 6, 2, '2342423', 'sdfssf', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'awarded', 9, 1769699774, 1769699797),
(15, 11, 2, 'aaaaa', 'ddddd', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'open', NULL, 1769701464, 1769701464),
(16, 11, 2, 'new request', 'sdsddsfd', 1.000, 'piece', 'Riyadh', NULL, NULL, '2026-01-31', NULL, NULL, '2026-02-02 09:00:00', 'awarded', 12, 1769701496, 1769701521);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int UNSIGNED NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_general_ci NOT NULL,
  `username` varchar(80) COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `auth_key` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `company_name` varchar(190) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(40) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `status` tinyint NOT NULL DEFAULT '10',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  `email_verified_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `email`, `username`, `password_hash`, `auth_key`, `role`, `company_name`, `phone`, `rating`, `status`, `created_at`, `updated_at`, `email_verified_at`) VALUES
(1, 'user.gmail.com', 'user', '$2y$13$YKfbCWE2Wmiv10xVGcLNcest7u.89.79CliCx7Abtfg8RW3XS.PlC', 'r2xkDl-PUZVyXoN4QwPEEA9FC1aAElM7', 'user', NULL, NULL, 0.00, 10, 1769461872, 1769461872, NULL),
(2, 'user@gmail.com', 'user1', '$2y$13$Q.dIUGzM7.2C7QzJhHX51OdJykbhntSF63MvTst8SimdthXyggn.i', 'feDBiFJwZwrHBHexOWoJKo-5ct-OxhnP', 'user', NULL, NULL, 0.00, 10, 1769461966, 1769465105, 1769465105),
(3, 'user2@gmail.com', 'user2', '$2y$13$Q.dIUGzM7.2C7QzJhHX51OdJykbhntSF63MvTst8SimdthXyggn.i', 'feDBiFJwZwrHBHexOWoJKo-5ct-OxhnP', 'user', NULL, NULL, 0.00, 10, 1769462120, 1769465529, 1769465529),
(4, 'test@gmail.com', 'test12', '$2y$13$.0QTqw0fCSugm7y6f6lGNu9.yPkw7PGb5n5qido5wXxjCz/CivIaC', '3Gp5T1wviA4ew3YHYTUEOPgaK3byq6Oe', 'user', NULL, NULL, 0.00, 10, 1769465557, 1769465560, 1769465560),
(5, 'company@gmail.com', 'company', '$2y$13$Q.dIUGzM7.2C7QzJhHX51OdJykbhntSF63MvTst8SimdthXyggn.i', 'MtKHYX6bxe9S8EdDmqoy6BQ5EcbE9qG4', 'company', 'company', NULL, 0.00, 10, 1769465604, 1769465606, 1769465606),
(6, 'user_test@gmail.com', 'user_test', '$2y$13$Zk4a7pNJ1kgjP57DlEH4vu7D3eLIgEsjaVclWKPqXYz8rb0Du03ni', 'MKDQ1gHna_xgcyZioJMmlkGcLX2lS6BC', 'user', NULL, NULL, 0.00, 10, 1769699452, 1769699455, 1769699455),
(7, 'company_test@gmail.com', 'username', '$2y$13$8JD/wRiKf6DhvUWf0MSqs.OKyUa3/HlgY509rOt5G5Pposrz..80q', 'KHWUvkVAUXC7PiEVvdSqX8UZvGVArWZ5', 'company', 'co 1', '+96181758449', 0.00, 10, 1769699537, 1769699539, 1769699539),
(8, 'aaa@gmail.com', 'asfsdf', '$2y$13$fJOfx.Uum72mtkrc1HSYwe3apZcrsdf3OQ3oApeP3gbZCfnTGBDOa', '7ppDmHVgsQTFG1XcUUKJeKdMrLAPfouq', 'user', NULL, NULL, 0.00, 10, 1769699853, 1769699854, 1769699854),
(9, 'aaa2@gmail.com', 'zzzzzzz2', '$2y$13$EkTAMfWEPgRhXQFZEQ0sneSsWYkuE4tYHskifBHlhMq6TZwh5UKci', 'l2Fjn5StMLnvZF4s1Tggx2hUIDyuvXia', 'user', NULL, NULL, 0.00, 10, 1769700854, 1769700858, 1769700858),
(10, 'test_uset@gmial.com', 'user12', '$2y$13$wUJxChhHG1HQ7rAsTLEd/./6iyovKjs690q.0XVJJ6C1q/AaPfmOe', 'KrixbhdrmNfZD2lQzN6sCFnwgZEBzoGw', 'user', NULL, NULL, 0.00, 10, 1769701249, 1769701251, 1769701251),
(11, 'testuser.1@gmial.com', 'username12', '$2y$13$lVy.VfZElt1bzYDLY5We9ufDCW3OwgI92swKuckVCtDJrGX4TdJvi', 'K7-pSsF8p_trSkVx1Y_WmKwGZof-7xdJ', 'user', NULL, NULL, 0.00, 10, 1769701347, 1769701356, 1769701356),
(12, 'company.test@gmail.com', 'co124', '$2y$13$gdQlj91gKNLeiKKZZxSANOUlYXKeFMXPOOwGUCG8Xd3gjMHICn1I2', '7VwQgL3pLFXaQzPf5kQpwYoOlD-m5XaX', 'company', 'co name', '+96181858442', 0.00, 10, 1769701403, 1769701405, 1769701405);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_category_name` (`name`);

--
-- Indexes for table `category_subscription`
--
ALTER TABLE `category_subscription`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uidx_category_subscription_user_category` (`user_id`,`category_id`),
  ADD KEY `idx_category_subscription_category` (`category_id`);

--
-- Indexes for table `migration`
--
ALTER TABLE `migration`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notification_recipient` (`recipient_user_id`,`created_at`);

--
-- Indexes for table `offer`
--
ALTER TABLE `offer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_offer_company` (`company_id`),
  ADD KEY `idx_offer_category` (`category_id`),
  ADD KEY `idx_offer_available_until` (`available_until`),
  ADD KEY `idx_offer_status` (`status`);

--
-- Indexes for table `otp`
--
ALTER TABLE `otp`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_email_purpose` (`email`,`purpose`,`created_at`),
  ADD KEY `idx_otp_user` (`user_id`),
  ADD KEY `idx_otp_expires` (`expires_at`);

--
-- Indexes for table `refresh_token`
--
ALTER TABLE `refresh_token`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_refresh_token_user` (`user_id`,`created_at`),
  ADD KEY `idx_refresh_token_expires` (`expires_at`);

--
-- Indexes for table `rfq_quotation`
--
ALTER TABLE `rfq_quotation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uidx_rfq_quotation_request_company` (`request_id`,`company_id`),
  ADD KEY `idx_rfq_quotation_request` (`request_id`),
  ADD KEY `idx_rfq_quotation_company` (`company_id`),
  ADD KEY `idx_rfq_quotation_status` (`status`);

--
-- Indexes for table `rfq_request`
--
ALTER TABLE `rfq_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rfq_request_user` (`user_id`),
  ADD KEY `idx_rfq_request_category` (`category_id`),
  ADD KEY `idx_rfq_request_expires` (`expires_at`),
  ADD KEY `fk_rfq_request_awarded_quotation` (`awarded_quotation_id`),
  ADD KEY `idx_rfq_request_status` (`status`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_user_role` (`role`),
  ADD KEY `idx_user_status` (`status`),
  ADD KEY `idx_user_email_verified` (`email_verified_at`),
  ADD KEY `idx_user_phone` (`phone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `category_subscription`
--
ALTER TABLE `category_subscription`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;

--
-- AUTO_INCREMENT for table `offer`
--
ALTER TABLE `offer`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `otp`
--
ALTER TABLE `otp`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `refresh_token`
--
ALTER TABLE `refresh_token`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `rfq_quotation`
--
ALTER TABLE `rfq_quotation`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `rfq_request`
--
ALTER TABLE `rfq_request`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `category_subscription`
--
ALTER TABLE `category_subscription`
  ADD CONSTRAINT `fk_category_subscription_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_category_subscription_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `fk_notification_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `offer`
--
ALTER TABLE `offer`
  ADD CONSTRAINT `fk_offer_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_offer_company` FOREIGN KEY (`company_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `otp`
--
ALTER TABLE `otp`
  ADD CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `refresh_token`
--
ALTER TABLE `refresh_token`
  ADD CONSTRAINT `fk_refresh_token_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `rfq_quotation`
--
ALTER TABLE `rfq_quotation`
  ADD CONSTRAINT `fk_rfq_quotation_company` FOREIGN KEY (`company_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rfq_quotation_request` FOREIGN KEY (`request_id`) REFERENCES `rfq_request` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `rfq_request`
--
ALTER TABLE `rfq_request`
  ADD CONSTRAINT `fk_rfq_request_awarded_quotation` FOREIGN KEY (`awarded_quotation_id`) REFERENCES `rfq_quotation` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rfq_request_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rfq_request_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
